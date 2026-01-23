# ~/.nixos-dotfiles

![sachi](home-manager/pfp/sachi.webp)

My personal [NixOS](https://nixos.org/) configuration, managed with [Nix Flakes](https://nixos.wiki/wiki/Flakes).

## ✨ Showcase

*Coming soon...*

## 📂 Structure

The repository is structured to separate concerns and make it easy to manage different parts of the system configuration.

- **flake.nix**: The entry point for the configuration. It defines the outputs, such as the NixOS and home-manager configurations.
- **nixos/**: Contains the system-wide configuration, including hardware-specific settings.
- **home-manager/**: Manages user-specific dotfiles and packages.
- **modules/**: Contains custom NixOS and home-manager modules.
- **overlays/**: Provides customizations and extra packages for the Nixpkgs.
- **pkgs/**: A place for custom packages.

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

There are two primary ways to manage your home environment with this setup:

#### 1. As part of the System Configuration (Recommended)

Home Manager is integrated as a NixOS module in this configuration. When you run `nixos-rebuild switch`, it builds not only the system but also your complete user environment as defined in `home-manager/home.nix`.

This is the most seamless approach, as it ensures your user environment is always in sync with your system configuration.

#### 2. Standalone Home Manager Activation

If you only want to update your user environment without rebuilding the entire system, you can use the `home-manager` command directly. This is useful for quickly testing changes to your dotfiles or user packages.

```sh
home-manager switch --flake .#<username>@<hostname>
```

- **`home-manager switch`**: This command builds your home environment and activates the new configuration.
- **`--flake .#<username>@<hostname>`**: This specifies the `homeConfigurations` output from your `flake.nix` to build.

This provides a faster iteration cycle when you are only concerned with your user-level settings.

## 🙏 Credits

This configuration is inspired by the many amazing dotfiles repositories in the NixOS community.
