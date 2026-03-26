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
{ ... }: {
  # Paste in your hardware configuration config fot host: ${HOST}
}
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

mkdir -p "$BASE_CONFIG_PATH/config/home-manager-config"

cat <<EOF >"$BASE_CONFIG_PATH/config/home-manager-config/default.nix"
{lib, ...}: {
  options.homeManager.enable = lib.mkEnableOption "Enable home manager module";
  config = {
    homeManager = {
      enable = true;
      apps = {
        enable = true;
        browsers = {
          enable = true;
          zen.enable = true;
          firefox.enable = true;
          floorp.enable = true;
        };
        social = {
          enable = true;
          discord.enable = true;
          whatsapp.enable = true;
          spotify.enable = true;
        };
        gaming = {
          enable = true;
          steam.enable = true;
          gamescope.enable = true;
        };
        productivity = {
          enable = true;
          obsidian.enable = true;
          sioyek.enable = true;
        };
        development = {
          enable = true;
          terminal = {
            enable = true;
            yazi.enable = true;
            zsh.enable = true;
            nushell.enable = true;
            tmux.enable = true;
            git.enable = true;
            ghostty.enable = true;
            neovim.enable = true;
            starship.enable = true;
          };
          api-clients = {
            enable = true;
            yaak.enable = true;
          };
          languages = {
            enable = true;
            go.enable = true;
            node.enable = true;
            markdown.enable = true;
            nix-lang.enable = true;
            sh.enable = true;
            c.enable = true;
            typescript.enable = true;
            lua.enable = true;
            python.enable = true;
            rust.enable = true;
            json.enable = true;
          };
          ai = {
            enable = true;
            crush.enable = true;
          };
          db = {
            enable = true;
            postgres.enable = true;
          };
          package-managers = {
            enable = true;
          };
        };
      };
      desktop = {
        enable = true;
        rofi.enable = false;
        wofi.enable = true;
        hyprland.enable = true;
        hyprlock.enable = true;
        waybar.enable = true;
      };
      system = {
        enable = true;
        fonts.enable = true;
        themes = {
          enable = true;
          catppuccin.enable = false;
          stylix.enable = true;
        };
        clipboard.enable = true;
      };
      hardware = {
        enable = true;
        qmk.enable = true;
      };
      misc = {
        enable = true;
        cli.enable = true;
      };
    };
  };
}
EOF

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

mkdir -p "$BASE_CONFIG_PATH/security"

cat <<EOF >"$BASE_CONFIG_PATH/security/sops.nix"
{
  meta,
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  environment.systemPackages = builtins.attrValues {inherit (pkgs) age sops;};

  sops = {
    age = {
      # Instructions:
      # mkdir -p ~/.config/sops/age
      # age-keygen -o ~/.config/sops/age/keys.txt
      # mkdir ~/.nixos-dotfiles/home-manager/secrets.yaml
      # Fill in your secrets in YAML format
      # sudo sops --encrypt  --in-place --age \$(sudo age-keygen -y /var/lib/sops-nix/age/key.txt) ~/.nixos-dotfiles/hosts/\${meta.hostname}/secrets.yaml
      # home-manager switch --flake .

      sshKeyPaths = ["/var/lib/sops-nix/.ssh/${HOST}"];
      keyFile = "/var/lib/sops-nix/age/key.txt";
    };
    secrets = {
      ${USERNAME}UserPassword = {
        sopsFile = ../secrets.yaml;
      };
    };
  };
}
EOF

cat <<EOF >"$BASE_CONFIG_PATH/secrets.yaml"
${USERNAME}UserPassword: "${USER_PASSWORD}"
EOF

exit 0
