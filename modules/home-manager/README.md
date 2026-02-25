# Home Manager Configuration

This directory contains the entire Home Manager configuration for the user `depaysement`. It's structured to be modular and easily maintainable.

## Structure

The configuration is divided into the following modules:

-   **`apps/`**: Contains configurations for all user applications, categorized by their purpose (e.g., browsers, development, gaming).
-   **`desktop/`**: Manages the desktop environment, including the window manager (Hyprland), status bar (Waybar), and other desktop-related tools.
-   **`system/`**: Handles system-level user configurations like fonts, themes, and clipboard management.
-   **`security/`**: Manages security-related aspects, primarily `sops-nix` for secret management.
-   **`scripts/`**: Includes custom scripts that are made available in the user's environment.

The main entry point is `default.nix`, which imports all the other modules and sets the overall configuration for the user.
