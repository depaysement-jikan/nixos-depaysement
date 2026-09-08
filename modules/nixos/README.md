# NixOS Modules

This directory contains generic and reusable NixOS modules. These modules define system-level configurations that can be enabled and configured on a per-host basis.

Every option lives under the `nixos-generic` namespace, and the configuration for these modules is centralized at the host level in `hosts/<host>/config/nixos-config/`.

## Structure

- **`desktop/`**: Comprehensive desktop environment configuration. Enabling `nixos-generic.desktop.enable` turns every sub-module on by default (`lib.mkDefault true`); set an individual sub-option to `false` to opt out.
  - **`sddm/`**: Simple Desktop Display Manager, themed with [SilentSDDM](https://github.com/uiriansan/SilentSDDM).
  - **`tuigreet/`**: A TTY login manager via `greetd`, launching Hyprland directly. Used as the alternative to SDDM.
  - **`hyprland/`**: Hyprland compositor and window manager configuration.
  - **`home-manager/`**: Integration of Home Manager as a NixOS module.
  - **`audio/`**: PipeWire with ALSA (incl. 32-bit), PulseAudio and JACK compatibility, WirePlumber, and `pavucontrol`. PulseAudio itself is disabled.
  - **`openLinkHub/`**: A systemd unit for [OpenLinkHub](https://github.com/jurkovic-nikola/OpenLinkHub) (Corsair iCUE device control) plus an nginx reverse proxy exposing its web UI on `rgb.localhost`.
- **`nix/`**: Global Nix daemon settings — flake support, the `pipe-operators` experimental feature, registry pinning to the flake inputs, and an emptied flake registry.
- **`scripts/`**: Automation scripts, packaged with `writeShellScriptBin` so they land on `PATH` after a rebuild.
  - **`mkHost.sh`**: A script to automate the creation of new NixOS host configurations.
  - **`mkUser.sh`**: A script to automate the creation of new NixOS user configurations.
  - **`resetSopsSecrets.sh`**: A script to facilitate the interactive resetting and re-encryption of SOPS secrets.
  - **`switch-monitor.sh`**: Toggles the Hyprland output between the laptop panel and an external monitor.
  - **`shared/`**: Shared shell functions used by the automation scripts.

> [!NOTE]
> The `scripts/` module is currently gated on `nixos-generic.desktop.sddm.enable`. On hosts that use
> tuigreet instead (`shinobu`, `yotsugi`) these commands are not installed, so run them from the
> repository with `sh ./modules/nixos/scripts/<script>.sh`.

## Usage

To use these modules, ensure they are imported in your host's `default.nix` and then configure them in your host-specific configuration file.

Example host configuration (`hosts/<host>/config/nixos-config/default.nix`):

```nix
{...}: {
  config = {
    nixos-generic = {
      desktop = {
        enable = true;
        sddm.enable = false;
        tuigreet.enable = true;
        hyprland.enable = true;
        homeManager.enable = true;
        audio.enable = true;
        openLinkHub.enable = true;
      };
    };
  };
}
```

Current per-host choices:

| Host        | sddm  | tuigreet | audio | openLinkHub |
| ----------- | ----- | -------- | ----- | ----------- |
| `shinobu`   | false | true     | true  | true        |
| `tsukinara` | true  | false    | true  | false       |
| `yotsugi`   | false | default  | true  | false       |
| `sodachi`   | true  | false    | true  | false       |

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
> This mkHost script does not set up disko at the moment. Copy an existing `hosts/<host>/disko/default.nix`
> and adjust the target device — the flake imports disko only when that directory exists.

### mkUser

The `mkUser.sh` script is an interactive tool designed to streamline the addition of new NixOS users to a host in this repository. It handles the boilerplate and security setup required for a new machine.

**Key Features:**

1.  **Automated Scaffolding**: Prompts for a parent hostname and username, then creates the complete directory structure in `hosts/<hostname>/users/<user>`, including configuration directories for Home Manager.
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

> [!NOTE]
> Both scripts scaffold files on disk only. The new host or user also has to be declared in
> [`nixos/configuration.nix`](../../nixos/configuration.nix) before the flake will build an output for it.

### resetSopsSecrets

The `resetSopsSecrets.sh` script is an interactive tool designed to facilitate the resetting and re-encryption of secrets for a specific user and host across the repository.

**Key Features:**

1.  **Selective Reset**: Allows the user to choose which secrets file to reset (Host-level, Home-Manager, or Homelab).
2.  **Interactive Value Entry**: Prompts the user for new values for each secret key in the file.
3.  **Automatic Key Handling**: Reuses or creates AGE and SSH keys as needed for encryption.
4.  **Automatic Re-encryption**: Uses `sops` to encrypt the file in-place with the updated values.

**Usage:**

```bash
resetSopsSecrets
```

> [!CAUTION]
> If you have not yet successfully run a NixOS rebuild, running `resetSopsSecrets` alone will not be sufficient, and you will need to run the command below

Run the script from the root of the repository:

```bash
sh ./modules/nixos/scripts/resetSopsSecrets.sh
```

### switch-monitor

Toggles the active Hyprland output between the internal laptop panel and an external monitor.

```bash
switch-monitor
```
