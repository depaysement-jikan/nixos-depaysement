#!/bin/bash

set -eu pipefail

locateAndSetRepoDir() {
  REPO_LOCATION="$HOME/.nixos-dotfiles"
  REPO_LOCATION_INPUT=$(nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#gum -- input --placeholder "Enter config repo location [${REPO_LOCATION}]:")
  REPO_LOCATION=${REPO_LOCATION_INPUT:-${REPO_LOCATION}}
  if [ ! -d "$REPO_LOCATION" ]; then
    echo -e "\n${RED}Error: Repo location is invalid."
    exit 1
  fi

  echo -e "${BLUE}Repo Location: ${NC}$REPO_LOCATION"
}

getUserInputForHostCreation() {
  HOST=$(nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#gum -- input --placeholder "Enter hostname:")
  [ -z "$HOST" ] && {
    echo -e "\n${RED}Error: Hostname cannot be empty"
    exit 1
  }

  BASE_CONFIG_PATH="$REPO_LOCATION/hosts/$HOST"

  if [ -d "$BASE_CONFIG_PATH" ]; then
    echo -e "\n${RED}Error: Host $HOST already exists"
    exit 1
  fi
  echo -e "${BLUE}Host: ${NC}$HOST"
}

getHostLocaleAndTimezone() {
  TIMEZONE=$(nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#gum -- input --placeholder "Enter time zone [America/Chicago]:")
  TIMEZONE=${TIMEZONE:-America/Chicago}

  echo -e "${BLUE}Timezone: ${NC}$TIMEZONE"

  LOCALE=$(nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#gum -- input --placeholder "Enter locale [en_US.UTF-8]:")
  LOCALE=${LOCALE:-en_US.UTF-8}

  echo -e "${BLUE}Locale: ${NC}$LOCALE"
}

createHostHardwareConfigPlaceholder() {
  mkdir -p "$BASE_CONFIG_PATH"

  cat <<EOF >"$BASE_CONFIG_PATH/hardware-configuration.nix"
  { ... }: {
    # Paste in your hardware configuration config fot host: ${HOST}
  }
EOF

  CREATED_FILES+=("$BASE_CONFIG_PATH/hardware-configuration.nix")
}

createHostDefaultConfig() {
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
    ./users
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

  networking.hostName = "${HOST}";
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

  CREATED_FILES+=("$BASE_CONFIG_PATH/default.nix")
}

createHostHomelabConfig() {
  mkdir -p "$BASE_CONFIG_PATH/config/homelab-config"

  cat <<EOF >"$BASE_CONFIG_PATH/config/homelab-config/default.nix"
{
  lib,
  config,
  ...
}: {
  options.homelab.enable = lib.mkEnableOption "Enable homelab module";
  config = {
    homelab = {
      enable = false;
      flux = {
        enable = true;
        bucketName = "panaino";
        endpoint = config.sops.placeholder.fluxEndpoint;
        accessKeyId = config.sops.placeholder.fluxAccessKeyId;
        secretAccessKey = config.sops.placeholder.fluxSecretKey;
        webhook = config.sops.placeholder.fluxDiscordWebhookUrl;
      };
      ingress = {
        enable = true;
        resources = {
          requests = {
            cpu = "100m";
            memory = "200Mi";
          };
          limits.memory = "400Mi";
        };
      };
      vaultwarden = {
        enable = true;
        replicas = 1;
        ingressHost = "vault.home";
        loadBalancerIP = "192.168.1.201";
        db = {
          resources = {
            requests = {
              memory = "130Mi";
            };
            limits.memory = "200Mi";
          };
        };
        resources = {
          requests = {
            memory = "50Mi";
          };
          limits.memory = "100Mi";
        };
      };
      databases = {
        enable = true;
        cloudnative-pg = {
          enable = true;
        };
      };
      metallb = {
        enable = true;
        replicas = 1;
        addresses = [
          "192.168.1.201-192.168.1.254"
        ];
      };
      longhorn = {
        # TODO: This is causing issues with flannel generation, disabled for now, Flux might fix it
        # context: https://github.com/k3s-io/k3s/issues/13277#issuecomment-3837472085
        enable = false;
        replicas = 1;
        ingressHost = "longhorn.home";
      };
      immich = {
        enable = true;
        replicas = 1;
        ingressHost = "immich.home";
        storageClass = "local-path";
        db = {
          instances = 1;
          size = "1Gi";
        };
      };
      pihole = {
        enable = true;
        password = config.sops.placeholder.piholePassword;
        gated = false;
        webLoadBalancerIP = "192.168.1.204";
        dnsLoadBalancerIP = "192.168.1.204";
        dns = "192.168.1.1";
      };
      cert-manager = {
        enable = true;
        email = config.sops.placeholder.certEmail;
      };
      tailscale = {
        enable = true;
        authKeyFile = config.sops.secrets.tailscaleAuthKey.path;
      };
      prometheus = {
        enable = false;
        ingressHost = "prometheus.home";
      };
      grafana = {
        enable = false;
        ingressHost = "grafana.home";
        loadBalancerIP = "192.168.1.210";
      };
      prometheus-stack = {
        enable = true;
        prometheus = {
          enable = false;
          ingressHost = "prometheus.home";
        };
        grafana = {
          enable = false;
          ingressHost = "grafana.home";
          loadBalancerIP = "192.168.1.210";
        };
      };
      uptime-kuma = {
        enable = true;
        ingressHost = "kuma.home";
        loadBalancerIP = "192.168.1.209";
      };
      forgejo = {
        enable = true;
        ingressHost = "forgejo.home";
        httpLoadBalancerIP = "192.168.1.212";
        sshLoadBalancerIP = "192.168.1.213";
      };

      # TODO: Future configs

      garage = {
        enable = true;
        ingressHost = null;
      };
    };
  };
}
EOF

  CREATED_FILES+=("$BASE_CONFIG_PATH/config/homelab-config/default.nix")
}

createHostNixosConfig() {
  mkdir -p "$BASE_CONFIG_PATH/config/nixos-config"

  cat <<EOF >"$BASE_CONFIG_PATH/config/nixos-config/default.nix"
{...}: {
  config = {
    nixos-generic = {
      desktop = {
        enable = true;
        sddm.enable = true;
        hyprland.enable = true;
        homeManager.enable = true;
      };
    };
  };
}
EOF

  CREATED_FILES+=("$BASE_CONFIG_PATH/config/nixos-config/default.nix")
}

printHostScriptResults() {
  echo -e "\n${YELLOW}Created files:\n"
  for f in "${CREATED_FILES[@]}"; do
    echo -e "${YELLOW}$f"
  done

  mapfile -t files < <(nix --extra-experimental-features "nix-command flakes pipe-operators" shell nixpkgs#fd -c fd --base-directory "${BASE_CONFIG_PATH}" yaml | grep homelab | grep secrets)

  printf "Please make sure you have either provided a valid key for all other secrets in this config. \n\n"

  RED="\033[0;31m"

  for f in "${files[@]}"; do
    echo -e "${RED}$f"
  done

  echo -e "\n${GREEN}Host ${HOST} has been fully generated!"
}
