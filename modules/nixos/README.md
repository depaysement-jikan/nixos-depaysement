# NixOS Modules

This directory contains generic and reusable NixOS modules. These modules define system-level configurations that can be enabled and configured on a per-host basis.

The configuration for these modules is centralized at the host level in `hosts/<host>/config/nixos-config/`.

## Structure

- **`desktop/`**: Comprehensive desktop environment configuration.
    - **`sddm/`**: Simple Desktop Display Manager setup with custom themes.
    - **`hyprland/`**: Hyprland compositor and window manager configuration.
    - **`home-manager/`**: Integration of Home Manager as a NixOS module.
- **`nix/`**: Global Nix daemon settings, including flake support and experimental features.

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
