# Home Manager Configuration

This directory contains the entire Home Manager configuration for a specific user. It's structured to be modular and easily maintainable.

The configuration values and actual enablement of features are now centralized at the host level in `hosts/<host>/users/<user>/config/home-manager-config/`. This allows for a clean separation between module definitions and host-specific settings.

## Structure

The configuration is divided into the following modules:

-   **`apps/`**: Defines options and basic configuration for user applications, categorized by their purpose (e.g., browsers, development, gaming, productivity, social).
-   **`desktop/`**: Manages the desktop environment components like Hyprland, Waybar, etc. Recent updates include Hyprland configuration tweaks such as adjusted window rounding and new window rules for specific applications.
-   **`system/`**: Handles general user-level configurations like fonts, themes, and clipboard.
-   **`scripts/`**: Includes custom scripts made available in the user's environment.
-   **`hardware/`**: Handles user-specific hardware configurations (e.g., QMK).
-   **`ssh-secrets/`**: Manages SSH public and private keys.
-   **`wallpapers/`**: Collection of system wallpapers and backgrounds.
-   **`misc/`**: Miscellaneous user-level configurations and packages (e.g., CLI tools like `fastfetch`).

The main entry point is `default.nix`, which imports all the sub-modules and handles general user setup. The actual enabling and configuration of these modules is controlled by the host-specific configuration.
