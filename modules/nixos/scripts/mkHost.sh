#!/bin/bash
set -eu pipefail

CREATED_FILES=()
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# shellcheck source=shared/generateUserConfigFunctions.sh
source "$SCRIPT_DIR/shared/generateUserConfigFunctions.sh"
# shellcheck source=shared/generateHostConfigFunctions.sh
source "$SCRIPT_DIR/shared/generateHostConfigFunctions.sh"

# locateAndSetRepoDir
#
# getUserInputForHostCreation
#
# getUserInputForUserCreation
#
# getHostLocaleAndTimezone
#
# createHostHardwareConfigPlaceholder
#
# createHostDefaultConfig
#
# createHostHomelabConfig
#
# createHostNixosConfig
#
# createUserDefaultConfig
#
# createUsersDefaultImports
#
# createUserHomeManagerConfig
#
# createUserSopsConfig
#
# createUserSecretsFile
#
# encryptUserSecrets

printHostScriptResults

exit 0
