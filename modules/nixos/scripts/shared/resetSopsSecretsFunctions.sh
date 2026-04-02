#!/bin/bash

set -eu pipefail

export GREEN="\033[0;32m"
export YELLOW="\033[1;33m"
export RED="\033[0;31m"
export BLUE="\033[0;34m"
export NC="\033[0m"

encryptSecrets() {
  if [[ $secretType == "User" ]]; then
    createKeys
  fi

  mapfile -t secretKeys < <(nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#yq -- -r 'keys[] | select(. != "sops")' "$1")

  local newSecretsFile=""

  for sk in "${secretKeys[@]}"; do
    echo -en "${BLUE}Enter a value for ${sk}: ${NC}"
    read -r VALUE
    if [[ $sk == "userHashedPassword" ]]; then
      VALUE=$(nix run nixpkgs#mkpasswd -- -m sha-512 "$VALUE")
    fi
    newSecretsFile+="$sk: $VALUE"$'\n'
  done

  newSecretsFile=$(echo "$newSecretsFile" | head -n -1)

  echo "$newSecretsFile" >"$1"

  sudo nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#sops -- \
    --encrypt \
    --in-place \
    --age "$(sudo nix --extra-experimental-features "nix-command flakes pipe-operators" shell nixpkgs#age -c age-keygen -y /var/lib/sops-nix/age/key.txt)" \
    "$1"
}

resetSecretsfromFileArray() {
  printf '%*s\n' "$(tput cols)" '' | tr ' ' '-'

  local SECRETS_FILES_EDITED=()
  local secretType="$1"
  local username="$2"
  shift
  shift
  local secretFiles=("$@")

  array_length=${#secretFiles[@]}

  printf "\n$secretType Secrets found: %s\n\n" "${array_length}"

  if [[ ${array_length} -eq 0 ]]; then
    return
  fi

  for f in "${secretFiles[@]}"; do
    while true; do
      echo -en "${BLUE}Do you want to reset the secrets at ${YELLOW}$f${BLUE}? [Y/n]: ${NC}"
      read -r SHOULD_EDIT
      SHOULD_EDIT=$(nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#gum -- input --placeholder "Do you want to reset the secrets at $f? [Y/n]:")

      SHOULD_EDIT="${SHOULD_EDIT:-y}"
      SHOULD_EDIT="${SHOULD_EDIT,,}"
      echo "$f"

      case "$SHOULD_EDIT" in
      y | yes)
        encryptSecrets "$f"
        SECRETS_FILES_EDITED+=("$f")
        break
        ;;
      n | no)
        echo -en "\n${RED}File Skipped\n\n"
        break
        ;;
      *)
        echo "Wrong input, please enter Y or N"
        ;;
      esac
    done
  done

  echo -en "\n${BLUE}$secretType Secrets Edited: ${NC}\n"

  for uf in "${SECRETS_FILES_EDITED[@]}"; do
    echo -e "${YELLOW}$uf"
  done

  echo -e "\n${GREEN}$secretType Secrets Successfully edited"
}

createKeys() {
  if [ -f "/var/lib/sops-nix/age/key.txt" ]; then
    echo "Age key exists at /var/lib/sops-nix/age/key.txt, it will be reused"
  else
    sudo mkdir -p /var/lib/sops-nix/age
    sudo --extra-experimental-features "nix-command flakes pipe-operators" nix shell nixpkgs#age -c age-keygen -o /var/lib/sops-nix/age/key.txt
  fi

  if [ -f "/var/lib/sops-nix/.ssh/$username" ]; then
    echo "SSH key for $username exists at /var/lib/sops-nix/.ssh/$username, it will be used"
  else
    sudo ssh-keygen -t ed25519 -f /var/lib/sops-nix/.ssh/"$username" -N ""
  fi
}

getUserInputForSecretReset() {
  USERNAME=$(nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#gum -- input --placeholder "Enter a username:")
  [ -z "$USERNAME" ] && {
    echo -en "${RED}Error: username cannot be empty"
    exit 1
  }

  if [ ! -d "$BASE_CONFIG_PATH/users/${USERNAME}" ]; then
    echo -e "\n${RED}Error: User $USERNAME does not exists"
    exit 1
  fi
}
