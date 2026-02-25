# ~/.nixos-dotfiles

<p align="center">
  <img src="modules/home-manager/pfp/sachi.webp" style="width:300px; height:auto;"/>
</p>

My personal [NixOS](https://nixos.org/) configuration, managed with [Nix Flakes](https://nixos.wiki/wiki/Flakes).

## ✨ Showcase

_Coming soon..._

## 🚀 Features

This NixOS configuration provides a comprehensive and reproducible environment with the following key features:

- **Declarative Configuration:** Leverages Nix Flakes for managing both system-wide (NixOS) and user-specific (Home Manager) configurations, ensuring reproducibility across different machines.
- **Homelab:** Includes a dedicated module for managing a homelab environment, with support for `k3s`, `FluxCD` for GitOps-driven container orchestration, `ingress-nginx` for advanced traffic management, `Pi-hole` for network-wide ad-blocking, `Vaultwarden` for secure password management, `Cert-manager` for automated SSL certificates, `MetalLB` for load balancing, `Longhorn` for distributed block storage, `Tailscale` for zero-config VPN, and `rclone` for syncing Kubernetes manifests to an S3 bucket.
- **Desktop Environment:** A modern and efficient desktop experience powered by [Hyprland](https://hyprland.org/), complemented by [Hyprlock](https://github.com/hyprwm/hyprlock) for a secure lock screen, [Wofi](https://hg.sr.ht/~scoopta/wofi) as an application launcher, and [Waybar](https://github.com/Alexays/Waybar) for a customizable status bar. Initial application launches on workspace start have been removed for a cleaner startup.
- **Robust Terminal Setup:** Features [Nushell](https://www.nushell.sh/) and [Zsh](https://www.zsh.org/) as shell options, [Starship](https://starship.rs/) for cross-shell prompt customization, [Tmux](https://github.com/tmux/tmux) for terminal multiplexing, deep Git integration, [Ghostty](https://github.com/Ghostty/Ghostty) as the terminal emulator, [Neovim](https://neovim.io/) for powerful text editing, and [Yazi](https://github.com/sxycode/yazi) as an efficient terminal file manager.
- **Extensive Development Environment:**
  - **Language Support:** Pre-configured environments for a wide array of programming languages including Go, Node.js, Nix-lang, Shell scripting, C, TypeScript, Lua, Python, Rust and PostgreSQL.
  - **API Clients:** Includes [Yaak](https://yaak.app/) for streamlined API development and testing.
  - **AI Tools:** Integration of [Crush](https://github.com/Crush-tool/crush), an AI-powered code assistant.

- **Web Browsing:** Utilizes [Zen Browser](https://zenbrowser.org/) for a privacy-focused browsing experience.
- **Aesthetic Customization:** Enhanced with custom fonts and a comprehensive theming system managed by [Stylix](https://github.com/danth/stylix).
- **Secure Secrets Management:** Integrates `sops-nix` for encrypting and securely managing sensitive data within the declarative configuration.
- **Custom Software & Overlays:** Provides a framework for custom packages and Nixpkgs overlays, allowing for personalized software versions and additions.
- **Essential Utilities:** Includes common command-line tools like `wget` and `nh` for Nix-specific operations.

For a detailed history of changes, please refer to the [CHANGELOG.md](CHANGELOG.md) file.

## 📂 File Tree

Here is a visual representation of the project structure:

<pre>
.
├── CHANGELOG.md
├── flake.lock
├── flake.nix
├── hosts
│   └── tsukinara
│       ├── default.nix
│       └── hardware-configuration.nix
├── modules
│   ├── homelab
│   │   ├── cert-manager
│   │   ├── cert-secrets.yaml
│   │   ├── databases
│   │   ├── default.nix
│   │   ├── flux
│   │   ├── garage
│   │   ├── ingress-nginx
│   │   ├── k3s
│   │   ├── longhorn
│   │   ├── metallb
│   │   ├── pihole
│   │   ├── pihole-secrets.yaml
│   │   ├── rclone
│   │   ├── README.md
│   │   ├── secrets.yaml
│   │   ├── security
│   │   ├── services
│   │   ├── tailscale
│   │   ├── tailscale-secrets.yaml
│   │   └── vaultwarden
│   ├── home-manager
│   │   ├── apps
│   │   ├── default.nix
│   │   ├── desktop
│   │   ├── pfp
│   │   ├── README.md
│   │   ├── scripts
│   │   ├── secrets.yaml
│   │   ├── security
│   │   ├── system
│   │   └── wallpapers
│   ├── nixos
│   │   ├── default.nix
│   │   └── nix
│   └── utils
│       └── default.nix
├── nixos
│   ├── configuration.nix
│   └── utils
│       └── options.nix
├── nvim
│   ├── init.lua
│   ├── lazy-lock.json
│   ├── lazyvim.json
│   ├── LICENSE
│   ├── lua
│   │   ├── config
│   │   └── plugins
│   ├── README.md
│   └── stylua.toml
├── overlays
│   └── default.nix
├── pkgs
│   └── default.nix
└── README.md
</pre>

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

1.  **Secret Definition (`modules/home-manager/security/sops.nix`):**
    - The `sops` configuration block defines which secrets to manage and how they should be handled.
    - Each secret, like `depaysementPassword`, is declared, and `sops-nix` expects to find its encrypted value in the `secrets.yaml` file.

2.  **Key Configuration:**
    - `sops-nix` uses AGE keys (or SSH keys) for encryption and decryption. You need to configure at least one key source.
    - `sops.age.keyFile`: Specifies the path to your AGE private key (e.g., `/home/depaysement/.config/sops/age/keys.txt`).
    - `sops.age.sshKeyPaths`: (Optional) Specifies a list of paths to SSH private keys that can be used as AGE keys.

3.  **`secrets.yaml` (Encrypted Secrets File):**
    - The `sops.defaultSopsFile` option points to your encrypted secrets file (e.g., `../../secrets.yaml`, which resolves to the project root's `secrets.yaml`).
    - This file contains your actual secrets in an encrypted format.

4.  **`flake.nix` `extraSpecialArgs`:**
    - The `sops.nix` module relies on `settings` and `meta` arguments (which are custom to this configuration) to construct paths for keys and other user-specific configurations.
    - These arguments (`settings.user` for your username and `meta.hostname` for your machine's hostname) are passed via `extraSpecialArgs` in your `flake.nix` to ensure the `sops.nix` module receives the correct context for path generation.

#### Setup Instructions

To get `sops-nix` working and manage your secrets:

1.  **Ensure `sops` and `age` are installed:**
    Make sure `pkgs.sops` and `pkgs.age` are included in your `home.packages` list in `modules/home-manager/default.nix`. After a successful `nixos-rebuild switch`, these tools will be available in your shell.

2.  **Generate an AGE private key (if you don't have one):**
    This key is crucial for decrypting your secrets. Store it securely and _do not_ commit it to Git.

    ```bash
    mkdir -p ~/.config/sops/age
    age-keygen -o ~/.config/sops/age/keys.txt
    ```

    **Important:** Back up this `keys.txt` file immediately! Losing it means permanent loss of access to your encrypted secrets.

3.  **Get your AGE public key:**
    You'll use this public key to encrypt your `secrets.yaml` file.

    ```bash
    age-keygen -y ~/.config/sops/age/keys.txt
    ```

    Copy the output (a string starting with `age1...`). This is your public key.

4.  **Create or encrypt your `secrets.yaml` file:**
    If you have an existing plain-text `secrets.yaml` (e.g., at `/home/depaysement/.nixos-dotfiles/secrets.yaml`), you can encrypt it in-place. If you're creating it from scratch, you can provide the content directly.
    - **Encrypting an existing plain-text `secrets.yaml` in-place:**
      Ensure your `secrets.yaml` file contains the plain-text secrets you wish to encrypt. For example:

      ```yaml
      depaysementPassword: your_actual_password
      depaysementGitUserName: your_github_username
      depaysementEmail: your_email@example.com
      depaysementGitName: Your Name
      ```

      Then run the encryption command:

      ```bash
      sops --encrypt --age "YOUR_AGE_PUBLIC_KEY" --in-place /home/depaysement/.nixos-dotfiles/secrets.yaml
      ```

      (Replace `"YOUR_AGE_PUBLIC_KEY"` with the public key from step 3).

    - **Creating a new, encrypted `secrets.yaml`:**
      ```bash
      sops --encrypt --age "YOUR_AGE_PUBLIC_KEY" /home/depaysement/.nixos-dotfiles/secrets.yaml <<EOF
      depaysementPassword: your_actual_password
      depaysementGitUserName: your_github_username
      depaysementEmail: your_email@example.com
      depaysementGitName: Your Name
      EOF
      ```
      (Replace `"YOUR_AGE_PUBLIC_KEY"` and the example values with your actual data).

5.  **Run NixOS Rebuild:**
    After your `secrets.yaml` is correctly encrypted and your keys are in place, apply your NixOS configuration:
    ```bash
    sudo nixos-rebuild switch --flake .#tsukinara
    ```
    This will activate the `sops-nix` service, which will decrypt and manage your secrets.

## 🙏 Credits

This configuration is inspired by the many amazing dotfiles repositories in the NixOS community.
