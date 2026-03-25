#!/bin/bash
set -eu pipefail

echo -n "Enter hostname: "
read -r HOST
[ -z "$HOST" ] && {
  echo "Error: Hostname cannot be empty"
  exit 1
}

echo -n "Enter a username: "
read -r USERNAME
[ -z "$USERNAME" ] && {
  echo "Error: username cannot be empty"
  exit 1
}

echo -n "Enter a password for the username: "
read -r USER_PASSWORD
[ -z "$USER_PASSWORD" ] && {
  echo "Error: password cannot be empty"
  exit 1
}
USER_PASSWORD=$(nix run nixpkgs#mkpasswd -- -m sha-512 "$USER_PASSWORD")

BASE_CONFIG_PATH="$HOME/.nixos-dotfiles/hosts/$HOST"
mkdir -p "$BASE_CONFIG_PATH/security"

echo -n "Enter time zone [America/Chicago]: "
read -r TIMEZONE
TIMEZONE=${TIMEZONE:-America/Chicago}

echo -n "Enter locale [en_US.UTF-8]: "
read -r LOCALE
LOCALE=${LOCALE:-en_US.UTF-8}

cat <<EOF >"$BASE_CONFIG_PATH/hardware-configuration.nix"
{ ... }: { }
EOF

cat <<EOF >"$BASE_CONFIG_PATH/default.nix"
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./security/sops.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = ["nix-command" "flakes" "pipe-operators"];
      flake-registry = "";
      nix-path = config.nix.nixPath;
    };
    channel.enable = false;

    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "\${n}=flake:\${n}") flakeInputs;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tsukinara";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [4200 3000];
    trustedInterfaces = ["cni0" "flannel.1"];
  };
  networking.networkmanager.dns = "none";

  networking.nameservers = [
    "192.168.1.204"
    "1.1.1.1"
  ];

  time.timeZone = "${TIMEZONE}";

  environment.shells = with pkgs; [zsh git];

  users.users.${USERNAME} = {
    isNormalUser = true;
    extraGroups = ["wheel" "k3s" "sddm"];
    packages = with pkgs; [tree kitty];
    shell = pkgs.zsh;
    hashedPassword = "${USER_PASSWORD}";
    homeMode = "711";
  };

  environment.systemPackages = with pkgs; [bind];
  programs.zsh.enable = true;

  services.openssh = {enable = true;};
  services.blueman.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  system.stateVersion = "25.11";
}
EOF

exit 0
