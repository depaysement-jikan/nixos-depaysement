# Changelog

## v1.0.8 - 2026-02-25

### Added

- **Longhorn:** Added a new module for Longhorn, a distributed block storage system for Kubernetes.
- **Tailscale:** Integrated Tailscale for zero-config VPN.
- **FluxCD:** Added the `fluxcd` package to the system packages.

### Changed

- **SOPS:** Added Tailscale secrets to sops.

## v1.0.7 - 2026-02-23

### Added

- **Pi-hole:** Integrated a working DNS and HTTPS for Pi-hole.
- **Vaultwarden:** Added Vaultwarden for secrets management.
- **Cert-manager:** Initial integration of cert-manager for automated certificate management.
- **MetalLB:** Initial setup for MetalLB for bare-metal load balancing.
- **Helm Autodeploy:** Built-in Helm autodeploy for streamlined application deployment.
- **LSP Packages:** Added more LSP-related packages for enhanced code editing.
- **Volume Key Support:** Added support for volume keys.
- **Bind Package:** Included the bind package for DNS utilities.
- **Gaming Module:** Added a new gaming module.
- **Clipboard History:** Added clipboard history support.

### Changed

- **HTTPS for Vault:** Enabled HTTPS for Vault.
- **Language Tweaks:** Made minor tweaks to language settings.
- **Ingress and Vault:** Updated ingress host and added notes on Vault.
- **SSH Key Name:** Updated the SSH key name.
- **Documentation:** Updated the documentation.

### Removed

- **Tmux Auto-initializer:** Removed the tmux auto-initializer.
- **Bind Shutdown:** Removed the bind shutdown command.

## v1.0.6 - 2026-02-15

### Added
- **Homelab Module:** Introduced a comprehensive homelab setup with:
  - `k3s` for lightweight Kubernetes orchestration.
  - `FluxCD` for GitOps-driven cluster synchronization.
  - `ingress-nginx` for managing external access to services.
  - `rclone` for syncing Kubernetes manifests to an S3 bucket.
- **PostgreSQL:** Added PostgreSQL to the development environment.
- **Desktop Utilities:**
  - `wlogout`: A graphical logout menu for Hyprland.
  - `swaync`: A notification daemon for Wayland.
  - `blueman`: A Bluetooth manager.

### Changed
- **Hyprlock:** The lock screen now uses a blurred screenshot of the current workspace for a more integrated look.
- **Waybar:** The status bar has been redesigned with a centered, more modern appearance.
- **Zsh:** Added the `k` alias for `kubectl` to streamline Kubernetes management.
- **Hyprland:** Increased window gaps for a more spacious feel.
- **User Groups:** Added the `depaysement` user to the `k3s` group.

## v1.0.4 - 2026-02-12

### Added

- **Nushell Support:** Integrated Nushell into the configuration.
- **Starship Support:** Added Starship prompt customization.

## v1.0.3 - 2026-02-10

### Changed

- **Updated `README.md`:**
  - Updated the file tree to reflect the current project structure.
  - Rewrote the "managing your configuration" section to explain the new workflow with `mkHost` and `mkHome`.
  - Removed the standalone home-manager activation part.
  - Updated the `sops-nix` section to reflect the new file structure.
  - Updated the image link to point to the correct location.
  - Removed the "My Home Configuration" section.

- **Refactored Configuration Structure:**
  - Switched to a host and loop system to set up home, users, and hosts, improving modularity and scalability.
  - Relocated the home-manager configuration to the `modules` directory for better organization.

## 2026-02-08

### Added

- **Firefox and Floorp:** Integrated Firefox and Floorp browsers into the configuration.
- **Social Apps:** Added a new `social` module with support for Discord and WhatsApp.

## 2026-02-07

### Changed

- **Simplified Screenshot Script:** The Hyprland screenshot script now uses `wl-copy` directly, removing the dependency on `satty`.
- **Cleaner Default Workspace:** The default Hyprland configuration no longer launches `ghostty`, `firefox`, or `discord` on startup, providing a cleaner initial workspace.

### Removed

- **Obsidian Integration:** Removed the dedicated Obsidian module, including the `git-sync-obsidian` service and related configurations.
- **Productivity Module:** The overarching `productivity` app module has been removed to streamline application categories.

## v1.0.1 - 2026-02-06

### New Features

*   **Modularized Language Packages:** Implemented modular organization for language-specific-development packages.
*   **Added Custom Scripts:** Introduced a collection of useful scripts for various tasks.
*   **Git Enhancements:** Added a set of convenient Git aliases and integrated initial Git configuration through Nix.
*   **Yaak Integration:** Yaak API client has been added as a Home Manager module.
*   **Go Language Server:** Included `gopls` for enhanced Go development experience.
*   **README Improvements:** Enhanced README with improved image centering and updated documentation post-tag push.

### Improvements & Fixes

*   **Module Reorganization:** Reordered modules for better structural clarity.
*   **Configuration Impurity Fixes:** Resolved issues related to impure configuration settings.
*   **Dependency Management:** Removed a duplicate GitHub installation and an unused variable.
*   **Secrets Management:** Implemented `sops` interpolation for Git configurations.
*   **Terminal Experience:** Temporarily disabled Tmux popups and suppressed SSH PID agent number display for a cleaner terminal output.
- **Documentation:** Updated README with feature descriptions and a detailed file tree.

## 2026-01-31

### Resolved sops-nix configuration issues

This session addressed multiple issues related to setting up `sops-nix` for secrets management within the Home Manager configuration.

**Key Changes & Fixes:**

*   **`home-manager/security/default.nix` updated:** Corrected an empty file that caused a `syntax error, unexpected end of file`. The file now correctly imports `sops.nix`.
*   **`flake.nix` `extraSpecialArgs` configured:** The `sops.nix` module required `settings` and `meta` arguments which were not being passed from `flake.nix`. These arguments, containing `user` and `hostname` information, were added to the `extraSpecialArgs` within the `homeConfigurations` block.
*   **`sops.age.keyFile` type clarification:** The `keyFile` option expects a string path, not a list. While the file content was technically correct, the missing `settings` argument masked this, leading to a "cannot coerce a list to a string" error. The explicit passing of `settings` and `meta` resolved the underlying issue.
*   **`sops` executable availability:** Ensured the `sops` command-line tool is available in the user's shell by confirming its inclusion in `home.packages` within `home-manager/home.nix`.
*   **`secrets.yaml` decryption:** Resolved issues where `sops-nix` failed to decrypt `secrets.yaml` (`Error getting data key: 0 successful groups required, got 0`). This involved ensuring `secrets.yaml` was correctly encrypted with the appropriate AGE public key and contained the expected secret keys as defined in `sops.nix`.
*   **`sops.age.sshKeyPaths` management:** Clarified the role and proper configuration of `sops.age.sshKeyPaths` for SSH key-based decryption, addressing potential "Cannot read ssh key" errors.

These changes collectively enabled the successful evaluation and activation of the `sops-nix` service, allowing for secure management of secrets.