#!/bin/bash

set -eu pipefail

export GREEN="\033[0;32m"
export YELLOW="\033[1;33m"
export RED="\033[0;31m"
export BLUE="\033[0;34m"
export NC="\033[0m"

resetSecretsfromFileArray() {
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
        # command ...
        SECRETS_FILES_EDITED+=("$f")
        break
        ;;
      n | no)
        echo "No Edit"
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
