# ~/.nixos-dotfiles

<p align="center">
  <img src="modules/home-manager/pfp/sachi.webp" style="width:300px; height:auto;"/>
</p>

My personal [NixOS](https://nixos.org/) configuration, managed with [Nix Flakes](https://nixos.wiki/wiki/Flakes).

## ✨ Showcase

_Coming soon..._

## Installation

If you want to use this configuration there are a couple of considerations to take into account, please review [INSTRUCTIONS.md](/INSTRUCTIONS.md), for NVIM setup instructions please refer to [INSTRUCTIONS-NVIM.md](/INSTRUCTIONS-NVIM.md)

## 🚀 Features

This NixOS configuration provides a comprehensive and reproducible environment with the following key features:

- **Declarative Configuration:** Leverages Nix Flakes for managing both system-wide (NixOS) and user-specific (Home Manager) configurations, ensuring reproducibility across different machines.
- **Disko Integration:** Uses [Disko](https://github.com/nix-community/disko) for declarative disk partitioning and formatting, managing host storage configurations.
- **Homelab:** Includes a dedicated module for managing a homelab environment, with support for `k3s`, `FluxCD` for GitOps-driven container orchestration, `ingress-nginx` for advanced traffic management, `Pi-hole` for network-wide ad-blocking (now with HTTPS), `Vaultwarden` for secure password management, `Cert-manager` for automated SSL certificates, `MetalLB` for load balancing, `Longhorn` for distributed block storage, `Immich` for self-hosted photo/video management (now with HTTPS), `Tailscale` for zero-config VPN, `Prometheus Stack` for unified monitoring and visualization (replacing standalone modules, now with HTTPS), `Uptime Kuma` for service status monitoring (now with HTTPS), `Forgejo` for a self-hosted Git service (now with HTTPS), and `rclone` for syncing Kubernetes manifests to an S3 bucket.
- **CI/CD:** Automated flake health checks and reproducibility validation using GitHub Actions and [flake-checker](https://github.com/DeterminateSystems/flake-checker).
- **Desktop Environment:** A modern and efficient desktop experience powered by [Hyprland](https://hyprland.org/), complemented by [Hyprlock](https://github.com/hyprwm/hyprlock) for a secure lock screen, [Wofi](https://hg.sr.ht/~scoopta/wofi) as an application launcher, and [Waybar](https://github.com/Alexays/Waybar) for a customizable status bar. Initial application launches on workspace start have been removed for a cleaner startup.
- **Robust Terminal Setup:** Features [Nushell](https://www.nushell.sh/) and [Zsh](https://www.zsh.org/) as shell options, [Starship](https://starship.rs/) for cross-shell prompt customization, [Tmux](https://github.com/tmux/tmux) for terminal multiplexing, deep Git integration, [Ghostty](https://github.com/Ghostty/Ghostty) as the terminal emulator, [Neovim](https://neovim.io/) for powerful text editing, and [Yazi](https://github.com/sxycode/yazi) as an efficient terminal file manager.
- **Extensive Development Environment:**
  - **Language Support:** Pre-configured environments for a wide array of programming languages including Go, Node.js, Nix-lang, Shell scripting, C, TypeScript, Lua, Python, Rust and PostgreSQL.
  - **API Clients:** Includes [Yaak](https://yaak.app/) for streamlined API development and testing.
  - **AI Tools:** Integration of [Crush](https://github.com/Crush-tool/crush), an AI-powered code assistant.
  - **Hardware:** Support for [QMK](https://qmk.fm/) for custom keyboard configuration.

- **Web Browsing:** Utilizes [Zen Browser](https://zenbrowser.org/) for a privacy-focused browsing experience.
- **Productivity & Social:** Includes [Spotify](https://www.spotify.com/) with Hyprland autostart and [Sioyek](https://sioyek.info/) for specialized technical PDF viewing.
- **Self-signed HTTPS:** Integrated self-signed certificate management for internal homelab services (Pi-hole, Immich, Prometheus Stack, Uptime Kuma) to enhance local network security.
- **Aesthetic Customization:** Enhanced with custom fonts and a comprehensive theming system managed by [Stylix](https://github.com/danth/stylix).
- **Secure Secrets Management:** Integrates `sops-nix` for encrypting and securely managing sensitive data at both the user (Home Manager) and host level.
- **Custom Software & Overlays:** Provides a framework for custom packages and Nixpkgs overlays, allowing for personalized software versions and additions.
- **Essential Utilities:** Includes common command-line tools like `wget` and `nh` for Nix-specific operations.

For a detailed history of changes, please refer to the [CHANGELOG.md](CHANGELOG.md) file.

## 📂 File Tree

Here is a visual representation of the project structure:

<pre>
.
├── .github
│   └── workflows
│       └── flake-check.yaml
├── CHANGELOG.md
├── flake.lock
├── flake.nix
├── hosts
│   └── tsukinara
│       ├── config
│       │   ├── homelab-config
│       │   └── nixos-config
│       ├── default.nix
│       ├── disko
│       │   └── default.nix
│       ├── hardware-configuration.nix
│       └── users
│           ├── default.nix
│           └── depaysement
│               ├── config
│               ├── default.nix
│               ├── secrets.yaml
│               └── security
├── modules
│   ├── homelab
│   │   ├── cert-manager
│   │   ├── databases
│   │   ├── default.nix
│   │   ├── flux
│   │   ├── forgejo
│   │   ├── garage
│   │   ├── grafana
│   │   ├── immich
│   │   ├── ingress-nginx
│   │   ├── k3s
│   │   ├── longhorn
│   │   ├── metallb
│   │   ├── pihole
│   │   ├── prometheus
│   │   ├── prometheus-stack
│   │   ├── rclone
│   │   ├── README.md
│   │   ├── secrets.yaml
│   │   ├── security
│   │   ├── services
│   │   ├── tailscale
│   │   ├── uptime-kuma
│   │   └── vaultwarden
│   ├── home-manager
│   │   ├── apps
│   │   ├── default.nix
│   │   ├── desktop
│   │   ├── misc
│   │   ├── pfp
│   │   ├── README.md
│   │   ├── scripts
│   │   ├── system
│   │   └── wallpapers
│   ├── nixos
│   │   ├── desktop
│   │   ├── default.nix
│   │   ├── nix
│   │   ├── README.md
│   │   └── scripts
│   └── utils
│       └── default.nix
├── nixos
│   ├── configuration.nix
│   └── utils
│       └── options.nix
├── nvim
│   └── (Neovim config)
├── overlays
│   └── default.nix
├── pkgs
│   └── default.nix
└── README.md
</pre>

## 🤖 Automation

This repository includes scripts to streamline common tasks.

### Host Creation

The `mkHost.sh` script automates the setup of a new NixOS host.

```bash
mkHost
```

> [!CAUTION]
> If you have not yes successfully run a NixOS rebuild, running `mkHost` alone will not be sufficient, and you will need to run the command below

Run the script from the root of the repository:

```bash
sh ./modules/nixos/scripts/mkHost.sh
```

This script will:

- Prompt for the new host name and user name.
- Create the directory structure in `hosts/<hostname>`.
- Generate a `default.nix` and `disko` configuration for the new host.
- Set up initial `sops` secrets for the user.
- Provide instructions on how to add the new host to `flake.nix`.

> [!NOTE]
> If you want to create any new hosts please refer to [mkHost script](modules/nixos/README.md#scripts)

## managing your configuration

This configuration is managed using Nix Flakes, which allows for reproducible and declarative system and user environments. Below are the primary commands you'll use to manage your setup.

### System-Wide Configuration

To apply the full system configuration, including packages, services, and system settings, you'll use `nixos-rebuild`.

```sh
sudo nixos-rebuild switch --flake .#<hostname>
```

- **`sudo nixos-rebuild switch`**: This command builds the NixOS configuration, and if the build is successful, it activates the new configuration immediately. It's the standard way to apply changes to your system.
- **`--flake .#<hostname>`**: This tells `nixos-rebuild` to use the flake in the current directory (`.`) and to build the output named `<hostname>`. Your `flake.nix` file defines one or more `nixosConfigurations`, each tied to a specific hostname.

Before switching, you can test a new configuration without making it the default boot entry:

```sh
sudo nixos-rebuild test --flake .#<hostname>
```

Or, you can build the configuration and add it to the boot menu without switching to it immediately:

```sh
sudo nixos-rebuild boot --flake .#<hostname>
```

### User Environment with Home Manager

This configuration uses [Home Manager](https://github.com/nix-community/home-manager) to declaratively manage user-specific files and packages. This allows your personal environment—your shell, editors, themes, and tools—to be as reproducible as your operating system.

Home Manager is integrated as a NixOS module in this configuration. When you run `nixos-rebuild switch`, it builds not only the system but also your complete user environment as defined in `modules/home-manager`.

This is the most seamless approach, as it ensures your user environment is always in sync with your system configuration.

### Secrets Management with `sops-nix`

This configuration leverages [`sops-nix`](https://github.com/Mic92/sops-nix) to securely manage sensitive data like API tokens, passwords, and other secrets within your declarative Home Manager setup. Secrets are encrypted in your Git repository and decrypted only at activation time on your local machine.

#### How it Works

1.  **Secret Definition (`hosts/<host>/users/<user>/security/sops.nix`):**
    - The `sops` configuration block defines which secrets to manage and how they should be handled at the user level.
    - Each secret, like `userPassword`, is declared, and `sops-nix` expects to find its encrypted value in the `secrets.yaml` file within the same user directory.

2.  **Key Configuration:**
    - `sops-nix` uses AGE keys (or SSH keys) for encryption and decryption. You need to configure at least one key source.
    - `sops.age.keyFile`: Specifies the path to your AGE private key (e.g., `/home/<user>/.config/sops/age/keys.txt`).
    - `sops.age.sshKeyPaths`: (Optional) Specifies a list of paths to SSH private keys that can be used as AGE keys.

3.  **`secrets.yaml` (Encrypted Secrets File):**
    - The `sops.defaultSopsFile` option points to your encrypted secrets file (e.g., `hosts/<host>/users/<user>/secrets.yaml`).
    - This file contains your actual secrets in an encrypted format.

4.  **`flake.nix` `extraSpecialArgs`:**
    - The `sops.nix` module relies on `settings` and `meta` arguments (which are custom to this configuration) to construct paths for keys and other user-specific configurations.
    - These arguments (`settings.user` for your username and `meta.hostname` for your machine's hostname) are passed via `extraSpecialArgs` in your `flake.nix` to ensure the `sops.nix` module receives the correct context for path generation.

## 🙏 Credits

This configuration is inspired by the many amazing dotfiles repositories in the NixOS community.
