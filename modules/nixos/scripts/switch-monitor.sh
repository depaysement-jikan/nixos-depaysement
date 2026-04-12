#!/usr/bin/env bash
set -euo pipefail

HYPRCTL="hyprctl"

# Get monitors
mapfile -t MONITORS < <($HYPRCTL monitors -j | nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#jq -- -r '.[].name')

INTERNAL=$(printf "%s\n" "${MONITORS[@]}" | grep -E "eDP|LVDS|DSI" || true)
EXTERNAL=$(printf "%s\n" "${MONITORS[@]}" | grep -vE "eDP|LVDS|DSI" | head -n1 || true)

if [[ -z "$INTERNAL" ]]; then
  echo "Switching to laptop mode"
  $HYPRCTL reload

  # laptop only
  $HYPRCTL keyword monitor "$EXTERNAL,disable"
  $HYPRCTL keyword monitor "$INTERNAL,preferred,0x0,1"
else
  echo "Switching to external mode"
  $HYPRCTL reload

  # external only
  $HYPRCTL keyword monitor "$INTERNAL,disable"
  $HYPRCTL keyword monitor "$EXTERNAL,preferred,auto,1"
fi
