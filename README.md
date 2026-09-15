# ~/.nixos-dotfiles

<p align="center">
  <img src="modules/home-manager/pfp/sachi.webp" style="width:300px; height:auto;"/>
</p>

My personal [NixOS](https://nixos.org/) configuration, managed with [Nix Flakes](https://nixos.wiki/wiki/Flakes) and tracking `nixos-unstable`.

## ✨ Showcase

_Coming soon..._

## Installation

If you want to use this configuration there are a couple of considerations to take into account, please review [INSTRUCTIONS.md](/INSTRUCTIONS.md), for NVIM setup instructions please refer to [INSTRUCTIONS-NVIM.md](/INSTRUCTIONS-NVIM.md)

## 🖥️ Hosts

Hosts are declared centrally in [`nixos/configuration.nix`](nixos/configuration.nix); `flake.nix` reads that
declaration and generates one `nixosConfigurations.<host>` and one `homeConfigurations.<user>@<host>` per entry.

| Host        | User          | Shell   | Profile | Disk (disko)   | Display manager | Notes                                                |
| ----------- | ------------- | ------- | ------- | -------------- | --------------- | ---------------------------------------------------- |
| `shinobu`   | `kokoro`      | nushell | desktop | `/dev/nvme0n1` | tuigreet        | Ryzen 9700X + RX 9060 XT, latest kernel, OpenLinkHub |
| `tsukinara` | `depaysement` | nushell | desktop | `/dev/nvme0n1` | SDDM            | Original host                                        |
| `yotsugi`   | `yay`         | zsh     | desktop | `/dev/nvme0n1` | tuigreet        | `stateVersion` 25.11                                 |
| `sodachi`   | `riddle`      | zsh     | desktop | `/dev/sda`     | SDDM            | SATA disk layout                                     |

The homelab stack is defined for every host but currently `homelab.enable = false` everywhere; flip it in
`hosts/<host>/config/homelab-config/default.nix` to bring up the k3s cluster.

## 🚀 Features

This NixOS configuration provides a comprehensive and reproducible environment with the following key features:

- **Declarative Configuration:** Leverages Nix Flakes for managing both system-wide (NixOS) and user-specific (Home Manager) configurations, ensuring reproducibility across different machines. Hosts and users are declared once in `nixos/configuration.nix` and the flake outputs are generated from that declaration.
- **Non-mutable User Accounts:** Enhanced security and reproducibility through non-mutable user account configurations.
- **Disko Integration:** Uses [Disko](https://github.com/nix-community/disko) for declarative disk partitioning and formatting. Disko is imported conditionally — a host only gets it when `hosts/<host>/disko/` exists.
- **Homelab:** Includes a dedicated module for managing a homelab environment, with support for `k3s` (a slim wrapper on top of upstream nixpkgs' `services.k3s` module — see `modules/homelab/services/k3s`), `FluxCD` for GitOps-driven container orchestration, `ingress-nginx` for advanced traffic management, `Pi-hole` for network-wide ad-blocking (now with HTTPS), `Vaultwarden` for secure password management, `Cert-manager` for automated SSL certificates, `MetalLB` for load balancing (with a central `homelab.metallb.claims` registry that fails the build on a double-booked LoadBalancer IP), `Longhorn` for distributed block storage, `Immich` for self-hosted photo/video management (now with HTTPS), `Tailscale` for zero-config VPN, `Prometheus Stack` for unified monitoring and visualization (replacing standalone modules, now with HTTPS), `Uptime Kuma` for service status monitoring (now with HTTPS), `Forgejo` for a self-hosted Git service (now with HTTPS), `Anubis` for per-service proof-of-work bot mitigation in front of Forgejo and Vaultwarden, `Garage` for object storage, and `rclone` for syncing Kubernetes manifests to an S3 bucket.
- **CI/CD:** GitHub Actions run `nix flake check` on every pull request and on pushes to `develop`, and mirror `develop` to a downstream repository with rewritten commit authorship.
- **Desktop Environment:** A modern and efficient desktop experience powered by [Hyprland](https://hyprland.org/), complemented by [Hyprlock](https://github.com/hyprwm/hyprlock) for a secure lock screen and a choice of shells and launchers: [Noctalia](https://github.com/noctalia-dev/noctalia) (the current default bar/shell, with plugins for screen recording, Bitwarden, SSH launching, color picking, file search and Tailscale status), [Waybar](https://github.com/Alexays/Waybar), [Wofi](https://hg.sr.ht/~scoopta/wofi) and [Rofi](https://github.com/davatorium/rofi). Login is handled by either [tuigreet](https://github.com/apognu/tuigreet) (via `greetd`) or [SDDM](https://github.com/sddm/sddm) with the [SilentSDDM](https://github.com/uiriansan/SilentSDDM) theme, selectable per host.
- **Audio:** PipeWire (ALSA, PulseAudio and JACK compatibility, plus WirePlumber) with `pavucontrol`, enabled through the `nixos-generic.desktop.audio` module.
- **Robust Terminal Setup:** Features [Nushell](https://www.nushell.sh/) and [Zsh](https://www.zsh.org/) as shell options, [Starship](https://starship.rs/) for cross-shell prompt customization, [Tmux](https://github.com/tmux/tmux) for terminal multiplexing, deep Git integration, [Ghostty](https://ghostty.org/) and [foot](https://codeberg.org/dnkl/foot) as terminal emulators, [Neovim](https://neovim.io/) for powerful text editing, [Yazi](https://github.com/sxyazi/yazi) as an efficient terminal file manager, [Certbot](https://certbot.eff.org/) for managing SSL certificates, and [Doppler](https://www.doppler.com/) for secrets injection.
- **Extensive Development Environment:**
  - **Language Support:** Pre-configured environments for a wide array of programming languages including Go, Node.js, TypeScript, Nix-lang, Shell scripting, C, Lua, Python, Rust, Zig, Elixir, JSON, Markdown and PostgreSQL.
  - **API Clients:** Includes [Yaak](https://yaak.app/) for streamlined API development and testing.
  - **AI Tools:** Integration of [Crush](https://github.com/charmbracelet/crush) and [Claude Code](https://claude.com/claude-code).
  - **Hardware:** Support for [QMK](https://qmk.fm/) for custom keyboard configuration and [OpenLinkHub](https://github.com/jurkovic-nikola/OpenLinkHub) for Corsair iCUE devices (with an nginx reverse proxy on `rgb.localhost`).
- **Web Browsing:** [Zen](https://zen-browser.app/), [Helium](https://github.com/oxcl/nix-flake-helium-browser), Firefox and [Floorp](https://floorp.app/) are all available and toggleable per user.
- **Productivity & Social:** Includes [Spotify](https://www.spotify.com/), [Obsidian](https://obsidian.md/), [Sioyek](https://sioyek.info/) for specialized technical PDF viewing, qbittorrent for managing downloads, plus Discord and WhatsApp.
- **Gaming:** Steam and Gamescope, gated behind the `homeManager.apps.gaming` options.
- **Self-signed HTTPS:** Integrated self-signed certificate management for internal homelab services (Pi-hole, Immich, Prometheus Stack, Uptime Kuma, Forgejo, Grafana, Vaultwarden, Anubis) to enhance local network security.
- **Aesthetic Customization:** Custom fonts (JetBrains Mono Nerd Font, Maple Mono NF) and a theming system with both [Stylix](https://github.com/danth/stylix) and [Catppuccin](https://github.com/catppuccin/nix) available, selectable per user.
- **Secure Secrets Management:** Integrates `sops-nix` for encrypting and securely managing sensitive data at both the user (Home Manager) and host level.
- **Custom Software & Overlays:** Provides a framework for custom packages (`pkgs/`) and Nixpkgs overlays (`overlays/`), plus a `downloadHelmChart` lib helper in `modules/utils/` used by the homelab modules.
- **Essential Utilities:** Includes common command-line tools like `wget`, `htop`, `fastfetch`, `clipse` and `nh` for Nix-specific operations.

For a detailed history of changes, please refer to the [CHANGELOG.md](CHANGELOG.md) file.

## 📂 File Tree

Here is a visual representation of the project structure:

<pre>
.
├── .github
│   ├── pull_request_template.md
│   └── workflows
│       ├── flake-check.yaml
│       └── mirror-config.yaml
├── CHANGELOG.md
├── INSTRUCTIONS.md
├── INSTRUCTIONS-NVIM.md
├── LICENSE
├── README.md
├── diagnostics-and-guides
│   ├── anubis.md
│   ├── ext4-root-corruption-runbook.md
│   ├── nixos-freezing-investigation.md
│   ├── nixos-unstable-migration-postmortem.md
│   └── systems-freeze-kernel.html
├── flake.lock
├── flake.nix
├── hosts
│   ├── shinobu            # kokoro
│   ├── sodachi             # riddle
│   ├── tsukinara          # depaysement
│   └── yotsugi             # yay
│       ├── config
│       │   ├── homelab-config
│       │   └── nixos-config
│       ├── default.nix
│       ├── disko
│       ├── hardware-configuration.nix
│       └── users
│           ├── default.nix
│           └── &lt;user&gt;
│               ├── config
│               │   └── home-manager-config
│               ├── default.nix
│               ├── secrets.yaml
│               └── security
├── modules
│   ├── homelab
│   │   ├── anubis
│   │   ├── cert-manager
│   │   ├── databases
│   │   ├── flux
│   │   ├── forgejo
│   │   ├── garage
│   │   ├── grafana
│   │   ├── immich
│   │   ├── ingress-nginx
│   │   ├── k3s
│   │   ├── longhorn
│   │   ├── metallb            # namespace, L2Advertisement, ipAddressPool, claims
│   │   ├── pihole
│   │   ├── prometheus
│   │   ├── prometheus-stack
│   │   ├── rclone
│   │   ├── security
│   │   ├── services
│   │   ├── tailscale
│   │   ├── uptime-kuma
│   │   ├── vaultwarden
│   │   ├── default.nix
│   │   └── README.md
│   ├── home-manager
│   │   ├── apps
│   │   │   ├── browsers        # zen, firefox, floorp, helium
│   │   │   ├── development     # terminal, languages, ai, db, api-clients
│   │   │   ├── gaming          # steam, gamescope
│   │   │   ├── productivity    # obsidian, sioyek, qbittorrent
│   │   │   └── social          # discord, whatsapp, spotify
│   │   ├── desktop             # hyprland, hyprlock, noctalia, waybar, wofi, rofi
│   │   ├── hardware            # qmk
│   │   ├── misc                # cli
│   │   ├── pfp
│   │   ├── scripts
│   │   ├── system              # fonts, themes, clipboard, openLinkHub
│   │   ├── wallpapers
│   │   ├── default.nix
│   │   └── README.md
│   ├── nixos
│   │   ├── desktop             # sddm, tuigreet, hyprland, home-manager, audio, openLinkHub
│   │   ├── nix
│   │   ├── scripts             # mkHost, mkUser, resetSopsSecrets, switch-monitor
│   │   ├── default.nix
│   │   └── README.md
│   └── utils
│       └── default.nix
├── nixos
│   ├── configuration.nix       # host / user declarations
│   └── utils
│       └── options.nix         # option schema for the above
├── nvim
│   └── (Neovim config)
├── overlays
│   └── default.nix
└── pkgs
    └── default.nix
</pre>

## 🤖 Automation

This repository includes scripts to streamline common tasks. They are packaged into the system
environment by `modules/nixos/scripts`, so they are available as plain commands after a rebuild.

### Host Creation

The `mkHost.sh` script automates the setup of a new NixOS host.

```bash
mkHost
```

### User Creation

The `mkUser.sh` script automates the setup of a new NixOS user to a host.

```bash
mkUser
```

### Secrets Reset

The `resetSopsSecrets.sh` script allows for interactive resetting and re-encryption of SOPS secrets across various modules.

```bash
resetSopsSecrets
```

### Monitor Switching

The `switch-monitor.sh` script toggles between the laptop panel and an external monitor under Hyprland.

```bash
switch-monitor
```

> [!CAUTION]
> If you have not yet successfully run a NixOS rebuild, running these scripts alone will not be sufficient, and you will need to run the commands below

Run the scripts from the root of the repository:

```bash
sh ./modules/nixos/scripts/mkHost.sh
sh ./modules/nixos/scripts/mkUser.sh
sh ./modules/nixos/scripts/resetSopsSecrets.sh
```

These scripts will:

- Prompt for the hostname and username.
- Iterate through secrets files in `hosts/`, `modules/home-manager/`, and `modules/homelab/`.
- Prompt for confirmation before editing and re-encrypting.

> [!NOTE]
> If you want to create any new hosts please refer to [mkHost script](modules/nixos/README.md#scripts)

## 🩺 Diagnostics & Guides

[`diagnostics-and-guides/`](diagnostics-and-guides) collects write-ups from real incidents on these machines,
plus deeper design research, because the useful output of both is usually a configuration change:

- [`ext4-root-corruption-runbook.md`](diagnostics-and-guides/ext4-root-corruption-runbook.md) — recovering a
  root filesystem that fails the stage-1 `fsck`, using `e2fsck` from the initrd shell.
- [`nixos-freezing-investigation.md`](diagnostics-and-guides/nixos-freezing-investigation.md) — an ongoing
  investigation into random freezes on `shinobu`, including hypotheses that were tried and ruled out.
- [`nixos-unstable-migration-postmortem.md`](diagnostics-and-guides/nixos-unstable-migration-postmortem.md) —
  the three failures hit when moving the flake from stable to `nixpkgs-unstable`, and their fixes.
- [`anubis.md`](diagnostics-and-guides/anubis.md) — architecture, deployment topologies (sidecar vs.
  forward-auth) and a staged plan of action for running [Anubis](https://github.com/TecharoHQ/anubis) in
  front of homelab services; the source for the `modules/homelab/anubis` module.

## managing your configuration

This configuration is managed using Nix Flakes, which allows for reproducible and declarative system and user environments. Below are the primary commands you'll use to manage your setup.

### System-Wide Configuration

To apply the full system configuration, including packages, services, and system settings, you'll use `nixos-rebuild`.

```sh
sudo nixos-rebuild switch --flake .#<hostname>
```

- **`sudo nixos-rebuild switch`**: This command builds the NixOS configuration, and if the build is successful, it activates the new configuration immediately. It's the standard way to apply changes to your system.
- **`--flake .#<hostname>`**: This tells `nixos-rebuild` to use the flake in the current directory (`.`) and to build the output named `<hostname>`. The `nixosConfigurations` outputs are generated from the host declarations in `nixos/configuration.nix`.

Before switching, you can test a new configuration without making it the default boot entry:

```sh
sudo nixos-rebuild test --flake .#<hostname>
```

Or, you can build the configuration and add it to the boot menu without switching to it immediately:

```sh
sudo nixos-rebuild boot --flake .#<hostname>
```

[`nh`](https://github.com/nix-community/nh) is installed for all users and is the shorthand used day to day:

```sh
nh os switch .#<hostname>
nh home switch .#<user>@<hostname>
```

### User Environment with Home Manager

This configuration uses [Home Manager](https://github.com/nix-community/home-manager) to declaratively manage user-specific files and packages. This allows your personal environment—your shell, editors, themes, and tools—to be as reproducible as your operating system.

Home Manager is wired in two ways:

1. As a NixOS module, enabled per host with `nixos-generic.desktop.homeManager.enable`, so that
   `nixos-rebuild switch` builds the system and the user environment together.
2. As standalone `homeConfigurations.<user>@<host>` flake outputs, so a user environment can be rebuilt on
   its own with `home-manager switch --flake .#<user>@<host>`.

Which modules are actually turned on is decided per user in
`hosts/<host>/users/<user>/config/home-manager-config/default.nix`.

### Secrets Management with `sops-nix`

This configuration leverages [`sops-nix`](https://github.com/Mic92/sops-nix) to securely manage sensitive data like API tokens, passwords, and other secrets within your declarative Home Manager setup. Secrets are encrypted in your Git repository and decrypted only at activation time on your local machine.

#### How it Works

1.  **Secret Definition (`hosts/<host>/users/<user>/security/sops.nix`):**
    - The `sops` configuration block defines which secrets to manage and how they should be handled at the user level.
    - Each secret, like `userPassword`, is declared, and `sops-nix` expects to find its encrypted value in the `secrets.yaml` file within the same user directory.

2.  **Key Configuration:**
    - `sops-nix` uses AGE keys (or SSH keys) for encryption and decryption. You need to configure at least one key source.
    - `sops.age.keyFile`: Specifies the path to your AGE private key (e.g., `/var/lib/sops-nix/age/keys.txt`).
    - `sops.age.sshKeyPaths`: (Optional) Specifies a list of paths to SSH private keys that can be used as AGE keys.

3.  **`secrets.yaml` (Encrypted Secrets File):**
    - The `sops.defaultSopsFile` option points to your encrypted secrets file (e.g., `hosts/<host>/users/<user>/secrets.yaml`).
    - This file contains your actual secrets in an encrypted format.

4.  **`flake.nix` `extraSpecialArgs`:**
    - The `sops.nix` module relies on `settings` and `meta` arguments (which are custom to this configuration) to construct paths for keys and other user-specific configurations.
    - These arguments (`settings.user` for your username and `meta.hostname` for your machine's hostname) are passed via `extraSpecialArgs` in your `flake.nix` to ensure the `sops.nix` module receives the correct context for path generation.

Homelab-wide secrets live alongside the modules instead: `modules/homelab/secrets.yaml`,
`pihole-secrets.yaml`, `cert-secrets.yaml` and `tailscale-secrets.yaml`.

## 🙏 Credits

This configuration is inspired by the many amazing dotfiles repositories in the NixOS community.

- [r0chd's nixconf](https://github.com/r0chd/nixconf)
- [redyf's nixdots](https://github.com/redyf/nixdots)
- [mysterio77's nix starter config](https://github.com/Misterio77/nix-starter-configs)
