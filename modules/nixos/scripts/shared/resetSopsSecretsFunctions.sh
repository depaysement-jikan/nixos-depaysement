#!/bin/bash

set -eu pipefail

export GREEN="\033[0;32m"
export YELLOW="\033[1;33m"
export RED="\033[0;31m"
export BLUE="\033[0;34m"
export NC="\033[0m"

resetSecretsfromFileArray() {
  printf '%*s\n' "$(tput cols)" '' | tr ' ' '.'

  local SECRETS_FILES_EDITED=()
  local secretType="$1"
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

      SHOULD_EDIT="${SHOULD_EDIT:-y}"
      SHOULD_EDIT="${SHOULD_EDIT,,}"

      case "$SHOULD_EDIT" in
      y | yes)
        encryptUserSecrets "$f"
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

encryptSecrets() {
  if [ -f "/var/lib/sops-nix/age/key.txt" ]; then
    echo "Age key exists at /var/lib/sops-nix/age/key.txt, it will be reused"
  else
    sudo mkdir -p /var/lib/sops-nix/age
    sudo nix shell nixpkgs#age -c age-keygen -o /var/lib/sops-nix/age/key.txt
  fi

  if [ -f "/var/lib/sops-nix/.ssh/$(whoami)" ]; then
    echo "SSH key for $(whoami) exists at /var/lib/sops-nix/.ssh/$(whoami), it will be used"
  else
    sudo ssh-keygen -t ed25519 -f /var/lib/sops-nix/.ssh/"$(whoami)" -N ""
  fi

  mapfile -t secretKeys < <(nix run nixpkgs#yq -- -r 'keys[] | select(. != "sops")' "$1")

  local newSecretsFile=""

  for sk in "${secretKeys[@]}"; do
    echo -en "${BLUE}Enter a value for ${sk}: ${NC}"
    read -r VALUE
    newSecretsFile+="$sk: $VALUE"$'\n'
  done

  newSecretsFile=$(echo "$newSecretsFile" | head -n -1)
  echo "$newSecretsFile" >"$1"

  sudo nix run nixpkgs#sops -- \
    --encrypt \
    --in-place \
    --age "$(sudo nix shell nixpkgs#age -c age-keygen -y /var/lib/sops-nix/age/key.txt)" \
    "$1"
}
