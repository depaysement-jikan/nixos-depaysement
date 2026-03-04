# Home Manager Configuration

This directory contains the entire Home Manager configuration for the user `depaysement`. It's structured to be modular and easily maintainable.

The configuration values and actual enablement of features are now centralized at the host level in `hosts/<host>/config/home-manager-config/`. This allows for a clean separation between module definitions and host-specific settings.

## Structure

The configuration is divided into the following modules:

-   **`apps/`**: Defines options and basic configuration for user applications, categorized by their purpose (e.g., browsers, development, gaming).
-   **`desktop/`**: Manages the desktop environment components like Hyprland, Waybar, etc.
-   **`system/`**: Handles general user-level configurations like fonts, themes, and clipboard.
-   **`security/`**: Manages security-related aspects, primarily `sops-nix`.
-   **`scripts/`**: Includes custom scripts made available in the user's environment.
-   **`hardware/`**: Handles user-specific hardware configurations (e.g., QMK).

The main entry point is `default.nix`, which imports all the sub-modules and handles general user setup. The actual enabling and configuration of these modules is controlled by the host-specific configuration.
