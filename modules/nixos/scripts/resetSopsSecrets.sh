#!/bin/bash
set -eu pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# shellcheck source=shared/resetSopsSecretsFunctions.sh
source "$SCRIPT_DIR/shared/resetSopsSecretsFunctions.sh"
# shellcheck source=shared/generateUserConfigFunctions.sh
source "$SCRIPT_DIR/shared/generateUserConfigFunctions.sh"
# shellcheck source=shared/generateHostConfigFunctions.sh
source "$SCRIPT_DIR/shared/generateHostConfigFunctions.sh"

locateAndSetRepoDir

getParentHostInputs

getUserInputForSecretReset

mapfile -t userSecrets < <(nix shell nixpkgs#fd -c fd --base-directory ~/.nixos-dotfiles yaml | grep host | grep users | grep "$USERNAME" | grep "$HOST")
resetSecretsfromFileArray "User" "$USERNAME" "${userSecrets[@]}"

mapfile -t homeManagerSecrets < <(nix shell nixpkgs#fd -c fd --base-directory ~/.nixos-dotfiles yaml | grep modules | grep home-manager)
resetSecretsfromFileArray "Home Manager" "$USERNAME" "${homeManagerSecrets[@]}"

mapfile -t homelabSecrets < <(nix shell nixpkgs#fd -c fd --base-directory ~/.nixos-dotfiles yaml | grep modules | grep homelab)
resetSecretsfromFileArray "Homelab" "$USERNAME" "${homelabSecrets[@]}"
