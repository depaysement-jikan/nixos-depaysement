#!/bin/bash
set -eu pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# shellcheck source=shared/resetSopsSecretsFunctions.sh
source "$SCRIPT_DIR/shared/resetSopsSecretsFunctions.sh"

mapfile -t userSecrets < <(nix shell nixpkgs#fd -c fd --base-directory ~/.nixos-dotfiles yaml | grep host | grep users)
resetSecretsfromFileArray "User" "${userSecrets[@]}"

mapfile -t homeManagerSecrets < <(nix shell nixpkgs#fd -c fd --base-directory ~/.nixos-dotfiles yaml | grep modules | grep home-manager)
resetSecretsfromFileArray "Home Manager" "${homeManagerSecrets[@]}"

mapfile -t homelabSecrets < <(nix shell nixpkgs#fd -c fd --base-directory ~/.nixos-dotfiles yaml | grep modules | grep homelab)
resetSecretsfromFileArray "Homelab" "${homelabSecrets[@]}"
