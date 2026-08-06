#!/bin/bash
set -eu pipefail

CREATED_FILES=()
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# shellcheck source=shared/generateUserConfigFunctions.sh
source "$SCRIPT_DIR/shared/generateUserConfigFunctions.sh"
# shellcheck source=shared/generateHostConfigFunctions.sh
source "$SCRIPT_DIR/shared/generateHostConfigFunctions.sh"

nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#gum -- style \
  --foreground 400 --border-foreground 400 --border double \
  --align center --margin "1 1" --padding "1 1" \
  'Host generator script'

locateAndSetRepoDir
getUserInputForHostCreation
getUserInputForUserCreation
getHostLocaleAndTimezone

echo -e "\n"

if nix --extra-experimental-features "nix-command flakes pipe-operators" \
  run nixpkgs#gum -- confirm "Do you want to move ahead with the host creation for $HOST?"; then

  createHostHardwareConfigPlaceholder
  createHostDefaultConfig
  createHostHomelabConfig
  createHostNixosConfig
  createUserDefaultConfig
  createUsersDefaultImports
  createUserHomeManagerConfig
  createUserSopsConfig
  createSshKeyAndAgeKey
  createUserSecretsFile
  encryptUserSecrets
  updateConfigurationNixHosts
  printHostScriptResults

else
  echo -e "\n${RED}Aborted"
  exit 1
fi

exit 0
