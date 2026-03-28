#!/bin/bash

set -eu pipefail

CREATED_FILES=()
MODIFIED_FILES=()
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# shellcheck source=shared/generateUserConfigFunctions.sh
source "$SCRIPT_DIR/shared/generateUserConfigFunctions.sh"
# shellcheck source=shared/generateHostConfigFunctions.sh
source "$SCRIPT_DIR/shared/generateHostConfigFunctions.sh"

locateAndSetRepoDir

getParentHostInputs

getUserInputForUserCreation

createUserDefaultConfig

createUserHomeManagerConfig

createUserSopsConfig

createUserSecretsFile

updateUsersDefaultImports

encryptUserSecrets

printUserScriptResults

exit 0
