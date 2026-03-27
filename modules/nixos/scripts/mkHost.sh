#!/bin/bash
set -eu pipefail

CREATED_FILES=()

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m"

REPO_LOCATION="$HOME/.nixos-dotfiles"

echo -en "${BLUE}Enter config repo location [${REPO_LOCATION}]: ${NC}"
read -r REPO_LOCATION_INPUT
REPO_LOCATION=${REPO_LOCATION_INPUT:-${REPO_LOCATION}}

echo -en "${BLUE}Enter hostname: ${NC}"
read -r HOST
[ -z "$HOST" ] && {
  echo -e "\n${RED}Error: Hostname cannot be empty"
  exit 1
}

BASE_CONFIG_PATH="$REPO_LOCATION/hosts/$HOST"

if [ -d "$BASE_CONFIG_PATH" ]; then
  echo -e "\n${RED}Error: Host $HOST already exists"
  exit 1
fi

echo -en "${BLUE}Enter a username: ${NC}"
read -r USERNAME
[ -z "$USERNAME" ] && {
  echo -en "${RED}Error: username cannot be empty"
  exit 1
}

echo -en "${BLUE}Enter a password for the username: ${NC}"
read -r USER_PASSWORD
[ -z "$USER_PASSWORD" ] && {
  echo -e "\n${RED}Error: password cannot be empty"
  exit 1
}

echo -en "${BLUE}Enter a GIT user name [none]: ${NC}"
read -r USER_GIT_NAME_INPUT
USER_GIT_NAME=${USER_GIT_NAME_INPUT:-none}

echo -en "${BLUE}Enter a GIT email [none]: ${NC}"
read -r USER_GIT_EMAIL_INPUT
USER_GIT_EMAIL=${USER_GIT_EMAIL_INPUT:-none\@email.com}

USER_PASSWORD=$(nix run nixpkgs#mkpasswd -- -m sha-512 "$USER_PASSWORD")

echo -en "${BLUE}Enter time zone [America/Chicago]: ${NC}"
read -r TIMEZONE
TIMEZONE=${TIMEZONE:-America/Chicago}

echo -en "${BLUE}Enter locale [en_US.UTF-8]: ${NC}"
read -r LOCALE
LOCALE=${LOCALE:-en_US.UTF-8}

mkdir -p "$BASE_CONFIG_PATH"

cat <<EOF >"$BASE_CONFIG_PATH/hardware-configuration.nix"
{ ... }: {
  # Paste in your hardware configuration config fot host: ${HOST}
}
EOF

CREATED_FILES+=("$BASE_CONFIG_PATH/hardware-configuration.nix")

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

mkdir -p "$BASE_CONFIG_PATH/users/${USERNAME}"

cat <<EOF >"$BASE_CONFIG_PATH/users/${USERNAME}/default.nix"
{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./security/sops.nix
  ];
  users.users.${USERNAME} = {
    isNormalUser = true;
    extraGroups = ["wheel" "k3s" "sddm"];
    packages = with pkgs; [tree kitty];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.userHashedPassword.path;
    homeMode = "711";
  };
}
EOF

CREATED_FILES+=("$BASE_CONFIG_PATH/users/${USERNAME}/default.nix")

mkdir -p "$BASE_CONFIG_PATH/users/${USERNAME}/config/home-manager-config"

cat <<EOF >"$BASE_CONFIG_PATH/users/${USERNAME}/config/home-manager-config/default.nix"
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

CREATED_FILES+=("$BASE_CONFIG_PATH/users/${USERNAME}/config/home-manager-config/default.nix")

mkdir -p "$BASE_CONFIG_PATH/users/${USERNAME}/security"

cat <<EOF >"$BASE_CONFIG_PATH/users/${USERNAME}/security/sops.nix"
{
  meta,
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  environment.systemPackages = builtins.attrValues {inherit (pkgs) age sops;};

  sops = {
    age = {
      sshKeyPaths = ["/var/lib/sops-nix/.ssh/${HOST}"];
      # Instructions:
      # mkdir -p /var/lib/sops-nix/age
      # age-keygen -o /var/lib/sops-nix/age/keys.txt
      # Fill in your secrets in YAML format
      # sudo sops --encrypt  --in-place --age \$(sudo age-keygen -y /var/lib/sops-nix/age/key.txt) ~/.nixos-dotfiles/hosts/${HOST}/users/${USERNAME}/secrets.yaml
      # sudo nixos-rebuild switch --flake .#tsukinara
      keyFile = "/var/lib/sops-nix/age/key.txt";
    };
    secrets = {
      userHashedPassword = {
        sopsFile = ../secrets.yaml;
      };
      userGitName = {
        sopsFile = ../secrets.yaml;
      };
      userGitEmail = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates.git-user = {
      path = "/home/${USERNAME}/.config/git/user.gitconfig";
      mode = "0644";
      owner = "${USERNAME}";
      content = ''
        [user]
          name = \${config.sops.placeholder.userGitName}
          email = \${config.sops.placeholder.userGitEmail}
      '';
    };
  };
}
EOF

CREATED_FILES+=("$BASE_CONFIG_PATH/users/${USERNAME}/security/sops.nix")

cat <<EOF >"$BASE_CONFIG_PATH/users/${USERNAME}/secrets.yaml"
userHashedPassword: "${USER_PASSWORD}"
userGitName: "${USER_GIT_NAME}"
userGitEmail: "${USER_GIT_EMAIL}"
EOF

CREATED_FILES+=("$BASE_CONFIG_PATH/users/${USERNAME}/secrets.yaml")

cat <<EOF >"$BASE_CONFIG_PATH/users/default.nix"
{...}: {
  imports = [
    ./${USERNAME}
  ];
}
EOF

CREATED_FILES+=("$BASE_CONFIG_PATH/users/default.nix")

if [ -f "/var/lib/sops-nix/age/key.txt" ]; then
  echo "Age key exists at /var/lib/sops-nix/age/key.txt, it will be reused"
else
  sudo mkdir -p /var/lib/sops-nix/age
  sudo nix shell nixpkgs#age -c age-keygen -o /var/lib/sops-nix/age/key.txt
fi

if [ -f "/var/lib/sops-nix/.ssh/${HOST}" ]; then
  echo "SSH key for ${HOST} exists at /var/lib/sops-nix/.ssh/${HOST}, it will be used"
else
  sudo ssh-keygen -t ed25519 -f /var/lib/sops-nix/.ssh/"${HOST}" -N "${HOST}"
fi

sudo nix run nixpkgs#sops -- \
  --encrypt \
  --in-place \
  --age "$(sudo nix shell nixpkgs#age -c age-keygen -y /var/lib/sops-nix/age/key.txt)" \
  "${REPO_LOCATION}"/hosts/"${HOST}"/users/"${USERNAME}"/secrets.yaml

echo -e "\n${YELLOW}Created files:\n"
for f in "${CREATED_FILES[@]}"; do
  echo -e "${YELLOW}$f"
done

echo -e "\n${GREEN}Host ${HOST} has been fully generated!"

exit 0
