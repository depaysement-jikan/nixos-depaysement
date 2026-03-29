# NixOS Modules

This directory contains generic and reusable NixOS modules. These modules define system-level configurations that can be enabled and configured on a per-host basis.

The configuration for these modules is centralized at the host level in `hosts/<host>/config/nixos-config/`.

## Structure

- **`desktop/`**: Comprehensive desktop environment configuration.
  - **`sddm/`**: Simple Desktop Display Manager setup with custom themes.
  - **`hyprland/`**: Hyprland compositor and window manager configuration.
  - **`home-manager/`**: Integration of Home Manager as a NixOS module.
- **`nix/`**: Global Nix daemon settings, including flake support, garbage collection, and experimental features.
- **`scripts/`**: Automation scripts for system maintenance and configuration.
  - **`mkHost.sh`**: A script to automate the creation of new NixOS host configurations.

## Usage

To use these modules, ensure they are imported in your host's `default.nix` and then configure them in your host-specific configuration file.

Example host configuration (`hosts/<host>/config/nixos-config/default.nix`):

```nix
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
```

## Scripts

### mkHost

The `mkHost.sh` script is an interactive tool designed to streamline the addition of new NixOS hosts to this repository. It handles the boilerplate and security setup required for a new machine.

**Key Features:**

1.  **Automated Scaffolding**: Prompts for a hostname and username, then creates the complete directory structure in `hosts/<hostname>/`, including configuration directories for both NixOS and Home Manager.
2.  **Configuration Generation**:
    - Generates a host `default.nix` that imports essential modules and sets up basic networking and system settings.
    - Creates module configuration templates for `homelab` and `nixos-generic`.
    - Sets up user-specific configurations and Home Manager integration.
3.  **Integrated Secrets Management**:
    - Prompts for a user password and securely hashes it using `mkpasswd`.
    - Automatically manages encryption keys in `/var/lib/sops-nix/` (AGE and SSH).
    - Generates an initial `secrets.yaml` for the user and encrypts it using `sops` with the host's AGE key.
4.  **Hardware & Locale**: Prompts for timezone and locale, and creates a template `hardware-configuration.nix`.

**Usage:**

```bash
mkHost
```

> [!CAUTION]
> If you have not yet successfully run a NixOS rebuild, running `mkHost` alone will not be sufficient, and you will need to run the command below

Run the script from the root of the repository:

```bash
sh ./modules/nixos/scripts/mkHost.sh
```

> [!TIP]
> This mkHost script does not set up disko at the moment.

### mkUser

The `mkUser.sh` script is an interactive tool designed to streamline the addition of new NixOS users to a host in this repository. It handles the boilerplate and security setup required for a new machine.

**Key Features:**

1.  **Automated Scaffolding**: Prompts for a parent hostname and username, then creates the complete directory structure in `hosts/<hostname>/users/<user>`, including configuration directories Home Manager.
2.  **Configuration Generation**:
    - Generates a host `default.nix` that imports essential modules and sets up basic networking and system settings.
    - Sets up user-specific configurations and Home Manager integration.
    - Updated the users default config, appending the new user to the array of imports.
3.  **Integrated Secrets Management**:
    - Prompts for a user password and securely hashes it using `mkpasswd`.
    - Automatically manages encryption keys in `/var/lib/sops-nix/` (AGE and SSH).
    - Generates an initial `secrets.yaml` for the user and encrypts it using `sops` with the host's AGE key.

**Usage:**

```bash
mkUser
```

> [!CAUTION]
> If you have not yet successfully run a NixOS rebuild, running `mkUser` alone will not be sufficient, and you will need to run the command below

Run the script from the root of the repository:

```bash
sh ./modules/nixos/scripts/mkUser.sh
```

> [!TIP]
> mkUser assumes you have a host to assign this user to, in case you do not, please use the mkHost script instead, as that initializes a user along with a host.
