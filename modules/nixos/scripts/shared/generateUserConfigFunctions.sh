#!/bin/bash

set -eu pipefail

export GREEN="\033[0;32m"
export YELLOW="\033[1;33m"
export RED="\033[0;31m"
export BLUE="\033[0;34m"
export NC="\033[0m"

getParentHostInputs() {
  HOST=$(nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#gum -- input --placeholder "Enter a parent host name:")
  [ -z "$HOST" ] && {
    echo -e "\n${RED}Error: Parent host cannot be empty"
    exit 1
  }
  BASE_CONFIG_PATH="$REPO_LOCATION/hosts/$HOST"
  if [ ! -d "$BASE_CONFIG_PATH" ]; then
    echo -e "\n${RED}Error: Host $HOST does not exist"
    exit 1
  fi
  echo -e "${BLUE}Host: ${NC}$HOST"
}

getUserInputForUserCreation() {
  USERNAME=$(nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#gum -- input --placeholder "Enter a username:")
  [ -z "$USERNAME" ] && {
    echo -en "${RED}Error: username cannot be empty"
    exit 1
  }
  if [ -d "$BASE_CONFIG_PATH/users/${USERNAME}" ]; then
    echo -e "\n${RED}Error: User $USERNAME already exists"
    exit 1
  fi
  echo -e "${BLUE}Username: ${NC}$USERNAME"
}

createUserDefaultConfig() {
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
    #TODO: this hashed password should only be used if there is certainty that the secrets are properly set and the key and ssh keys for sops are placed in the right spot
    # hashedPasswordFile = config.sops.secrets.userHashedPassword.path;
    password = "12345"
    homeMode = "711";
  };
  users.mutableUsers = false;
}
EOF

  CREATED_FILES+=("$BASE_CONFIG_PATH/users/${USERNAME}/default.nix")
}

createUserHomeManagerConfig() {
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
          qbittorrent.enable = true;
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
            certbot.enable = true;
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

}

createUserSopsConfig() {
  mkdir -p "$BASE_CONFIG_PATH/users/${USERNAME}/security"

  cat <<EOF >"$BASE_CONFIG_PATH/users/${USERNAME}/security/sops.nix"
{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  environment.systemPackages = builtins.attrValues {inherit (pkgs) age sops;};

  sops = {
    age = {
      sshKeyPaths = ["/var/lib/sops-nix/.ssh/${USERNAME}"];
      # Instructions:
      # mkdir -p /var/lib/sops-nix/age
      # age-keygen -o /var/lib/sops-nix/age/keys.txt
      # Fill in your secrets in YAML format
      # sudo sops --encrypt  --in-place --age \$(sudo age-keygen -y /var/lib/sops-nix/age/key.txt) ${REPO_LOCATION}/hosts/${HOST}/users/${USERNAME}/secrets.yaml
      # sudo nixos-rebuild switch --flake .#tsukinara
      keyFile = "/var/lib/sops-nix/age/key.txt";
    };
    secrets = {
      userHashedPassword = {
        neededForUsers = true;
        sopsFile = ../secrets.yaml;
      };
      userGitName = {
        sopsFile = ../secrets.yaml;
      };
      userGitEmail = {
        sopsFile = ../secrets.yaml;
      };
      userPublicSshKey = {
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
          signingkey = "/home/kokoro/.ssh/kokoro.pub"
      '';
    };
    templates.allowed-signers = {
      path = "/home/${USERNAME}/.config/git/allowed-signers";
      mode = "0644";
      owner = "${USERNAME}";
      content = ''
        \${config.sops.placeholder.userGitEmail} \${config.sops.placeholder.userPublicSshKey}
      '';
    };
  };
}
EOF

  CREATED_FILES+=("$BASE_CONFIG_PATH/users/${USERNAME}/security/sops.nix")
}

createSshKeyAndAgeKey() {
  if [ -f "/var/lib/sops-nix/age/key.txt" ]; then
    echo "Age key exists at /var/lib/sops-nix/age/key.txt, it will be reused"
  else
    sudo mkdir -p /var/lib/sops-nix/age
    sudo nix --extra-experimental-features "nix-command flakes pipe-operators" shell nixpkgs#age -c age-keygen -o /var/lib/sops-nix/age/key.txt
  fi

  if [ -f "/var/lib/sops-nix/.ssh/${USERNAME}" ]; then
    echo "SSH key for ${USERNAME} exists at /var/lib/sops-nix/.ssh/${USERNAME}, it will be used"
  else
    sudo ssh-keygen -t ed25519 -f /var/lib/sops-nix/.ssh/"${USERNAME}" -N ""
  fi
}

createUserSecretsFile() {
  USER_PASSWORD=$(nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#gum -- input --placeholder "Enter a password for the username:" --password)
  [ -z "$USER_PASSWORD" ] && {
    echo -e "\n${RED}Error: password cannot be empty"
    exit 1
  }
  echo -e "${BLUE}User Password: ${NC}$(printf '%*s\n' ${#USER_PASSWORD} '' | tr ' ' '*')"

  USER_GIT_NAME_INPUT=$(nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#gum -- input --placeholder "Enter a GIT user name [none]:")
  USER_GIT_NAME=${USER_GIT_NAME_INPUT:-none}
  echo -e "${BLUE}Git name: ${NC}$USER_GIT_NAME"

  USER_GIT_EMAIL_INPUT=$(nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#gum -- input --placeholder "Enter a GIT email [none]:")
  USER_GIT_EMAIL=${USER_GIT_EMAIL_INPUT:-none\@email.com}
  echo -e "${BLUE}Git email: ${NC}$USER_GIT_EMAIL"

  USER_PASSWORD=$(nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#mkpasswd -- -m sha-512 "$USER_PASSWORD")

  cat <<EOF >"$BASE_CONFIG_PATH/users/${USERNAME}/secrets.yaml"
  userHashedPassword: "${USER_PASSWORD}"
  userGitName: "${USER_GIT_NAME}"
  userGitEmail: "${USER_GIT_EMAIL}"
  userPublicSshKey: "$(sudo cat /var/lib/sops-nix/.ssh/"$USERNAME".pub)"
EOF

  CREATED_FILES+=("$BASE_CONFIG_PATH/users/${USERNAME}/secrets.yaml")
}

updateUsersDefaultImports() {
  TEMP=$(head "$BASE_CONFIG_PATH"/users/default.nix -n -2)
  printf "%s\n" "$TEMP" >"$BASE_CONFIG_PATH/users/default.nix"
  cat <<EOF >>"$BASE_CONFIG_PATH/users/default.nix"
      ./${USERNAME}
    ];
  }
EOF

  MODIFIED_FILES+=("$BASE_CONFIG_PATH/users/default.nix")
}

createUsersDefaultImports() {
  mkdir -p "$BASE_CONFIG_PATH/users/${USERNAME}"
  cat <<EOF >>"$BASE_CONFIG_PATH/users/default.nix"
{...}: {
  imports = [
    ./${USERNAME}
  ];
}
EOF

  CREATED_FILES+=("$BASE_CONFIG_PATH/users/default.nix")
}

encryptUserSecrets() {
  sudo nix --extra-experimental-features "nix-command flakes pipe-operators" run nixpkgs#sops -- \
    --encrypt \
    --in-place \
    --age "$(sudo nix --extra-experimental-features "nix-command flakes pipe-operators" shell nixpkgs#age -c age-keygen -y /var/lib/sops-nix/age/key.txt)" \
    "${REPO_LOCATION}"/hosts/"${HOST}"/users/"${USERNAME}"/secrets.yaml
}

printUserScriptResults() {
  echo -e "\n${YELLOW}Created files:\n"
  for f in "${CREATED_FILES[@]}"; do
    echo -e "${YELLOW}$f"
  done

  echo -e "\n${YELLOW}Modified files:\n"
  for f in "${MODIFIED_FILES[@]}"; do
    echo -e "${YELLOW}$f"
  done

  echo -e "\n${GREEN}User ${USERNAME} has been fully generated for host ${HOST}!"
}
