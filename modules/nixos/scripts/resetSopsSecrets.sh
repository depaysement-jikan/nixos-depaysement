#!/bin/bash
set -eu pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# shellcheck source=shared/resetSopsSecretsFunctions.sh
source "$SCRIPT_DIR/shared/resetSopsSecretsFunctions.sh"
# shellcheck source=shared/generateUserConfigFunctions.sh
source "$SCRIPT_DIR/shared/generateUserConfigFunctions.sh"
# shellcheck source=shared/generateHostConfigFunctions.sh
source "$SCRIPT_DIR/shared/generateHostConfigFunctions.sh"

nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#gum -- style \
  --foreground 400 --border-foreground 400 --border double \
  --align center --margin "1 1" --padding "1 1" \
  'Secret reset screen'

locateAndSetRepoDir
getParentHostInputs
getUserInputForSecretReset

echo -e "\n"

if nix --extra-experimental-features "nix-command flakes pipe-operators" \
  run nixpkgs#gum -- confirm "Do you want to move ahead with the secret reset for host $HOST and user $USERNAME?"; then

  mapfile -t userSecrets < <(nix --extra-experimental-features "nix-command flakes pipe-operators" shell nixpkgs#fd -c fd --base-directory "$REPO_LOCATION" yaml | grep host | grep users | grep "$USERNAME" | grep "$HOST")
  if ((${#userSecrets[@]} > 0)); then
    resetSecretsfromFileArray "User" "$USERNAME" "${userSecrets[@]}"
  fi

  mapfile -t homeManagerSecrets < <(nix --extra-experimental-features "nix-command flakes pipe-operators" shell nixpkgs#fd -c fd --base-directory "$REPO_LOCATION" yaml | grep modules | grep home-manager)
  if ((${#homeManagerSecrets[@]} > 0)); then
    resetSecretsfromFileArray "Home Manager" "$USERNAME" "${homeManagerSecrets[@]}"
  fi

  mapfile -t homelabSecrets < <(nix --extra-experimental-features "nix-command flakes pipe-operators" shell nixpkgs#fd -c fd --base-directory "$REPO_LOCATION" yaml | grep modules | grep homelab)
  if ((${#homelabSecrets[@]} > 0)); then
    resetSecretsfromFileArray "Homelab" "$USERNAME" "${homelabSecrets[@]}"
  fi

else
  echo -e "\n${RED}Aborted"
  exit 1
fi

exit 0
