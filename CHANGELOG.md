# Changelog

## v1.0.22 - 2026-04-04

### Added

- **Automation:**
  - Introduced `resetSopsSecrets.sh` to facilitate interactive secret resetting and re-encryption for hosts, Home Manager, and homelab modules.
  - Added `shared/resetSopsSecretsFunctions.sh` to centralize secret management logic.
  - Integrated `gum` into automation scripts (`mkHost.sh`, `mkUser.sh`, `resetSopsSecrets.sh`) for a more interactive and visually appealing CLI experience.
- **Infrastructure:**
  - Added a new host `shinobu` and user `kokoro`.

### Changed

- **Automation:**
  - Improved `mkHost.sh` and `mkUser.sh` with enhanced UI using `gum`, including confirmation prompts and stylized headers.
  - Refactored internal script logic to use `REPO_LOCATION` variables for better portability.
  - Fixed an issue where scripts were not correctly compiled into the NixOS system environment.
  - Enhanced script robustness by adding more conditional checks and improving shell script formatting/tabbing.
- **Infrastructure:**
  - Simplified user directory structure by removing redundant nested folders, promoting a flatter and more intuitive hierarchy.

### Fixed

- **Automation:** Resolved issues with incorrect tabbing in generated Nix files and improved overall script reliability.

## v1.0.21 - 2026-03-29

### Added

- **Automation:**
  - Introduced `mkUser.sh` script to automate the addition of new users to existing hosts.
  - Added shared configuration logic in `modules/nixos/scripts/shared/` to support modular script generation for hosts and users.
- **Documentation:**
  - Integrated GitHub-style "Note", "Tip", and "Caution" blocks for clearer warnings and suggestions.
  - Added deep links to relevant sections for better navigation within the documentation.
  - Added warnings about initial NixOS rebuild requirements before using automation scripts.

### Changed

- **Automation:**
  - Major refactoring of `mkHost.sh` to utilize new shared logic for host and user creation, improving maintainability.
  - Improved `mkHost` and `mkUser` scaffolding to handle secrets more robustly at the user level.
- **Security:**
  - Refined secrets management by moving `secrets.yaml` and `sops.nix` to individual user directories (`hosts/<host>/users/<user>`).
  - Added warnings about other secrets files to prevent potential misconfiguration of sensitive data.
- **Git Configuration:**
  - Enabled SSH-based GPG signing and configured `allowedSignersFile` for commit verification.
  - Updated SSH identity handling to use user-specific keys instead of host keys.
- **Documentation:**
  - Cleaned up the root `README.md` project structure to remove redundant entries.
  - Modularized and updated setup instructions in `INSTRUCTIONS.md`.
  - Updated the `modules/nixos` README with detailed feature descriptions and usage guides for automation scripts.

### Fixed

- **Automation:**
  - Fixed an issue where `mkHost.sh` failed to generate a necessary `default.nix` in the host directory.

## v1.0.20 - 2026-03-26

### Added

- **Automation:**
  - Introduced `mkHost.sh` script to automate the creation of new NixOS host configurations. This script generates the necessary directory structure, `default.nix`, `disko` configuration, and initial `sops` secrets.
- **Infrastructure:**
  - Added conditional disko imports in `flake.nix`, allowing for better flexibility when a host does not require disko.
- **Home Manager:**
  - Added a new `users` directory structure within each host to allow for per-user configurations and secrets.
  - Relocated user password management to the user level within the host configuration.

### Changed

- **Infrastructure:**
  - Refactored host organization to use a unified `hosts/<host>/users/<user>` structure, improving multi-user and multi-host scalability.
- **Security:**
  - Moved Git secrets and SSH secrets to the user-specific configuration level, enhancing security isolation.
- **CI/CD:**
  - Updated `flake-check.yaml` workflow with improved error handling.
  - Fixed various CI pipeline issues to ensure reliable flake validation.

### Fixed

- **Home Manager:** Resolved issues with Git secrets not being correctly applied at the user level.

## v1.0.19 - 2026-03-23

### Added

- **Homelab:**
  - Integrated `Forgejo`, a self-hosted Git service, into the homelab with self-signed HTTPS certificate management.
- **CI/CD:**
  - Added a GitHub Action to mirror the repository to a dedicated organization.
- **Documentation:**
  - Added `INSTRUCTIONS.md` for a comprehensive setup guide of the configuration.
  - Added `INSTRUCTIONS-NVIM.md` for manual Neovim configuration steps.
- **Shell:**
  - Added `.envrc` with `direnv` support for automatic Nix environment loading.

### Changed

- **Home Manager:**
  - Improved modularity by dynamically resolving the username and home directory from the `settings` variable.
- **Infrastructure:**
  - Cleaned up `flake.nix` by removing redundant comments and unused code.
- **Documentation:**
  - Updated root `README.md` with installation links and project structure updates.
  - Enhanced NixOS module documentation in `modules/nixos/README.md`.

## v1.0.18 - 2026-03-20

### Added

- **Home Manager:**
  - Introduced a new `misc` module for miscellaneous user configurations.
  - Added a `cli` submodule within `misc` to manage common CLI tools like `cbonsai`, `lolcat`, and `fastfetch`.
  - Added a `package-managers` submodule to `apps/development` for centralized management of package-related tools (e.g., `wget`).

### Changed

- **Home Manager:**
  - Refactored `modules/home-manager/default.nix` to improve modularity by moving package declarations to their respective submodules.
  - Cleaned up unused imports and improved internal module structure.
- **Documentation:**
  - Updated root `README.md` and `modules/home-manager/README.md` to reflect the new `misc` module and updated file tree.
  - Enhanced `modules/nixos/README.md` with more detailed descriptions of the NixOS module structure.

## v1.0.17 - 2026-03-19

### Changed

- **NixOS Modularization:**
  - Refactored NixOS configurations into a modular and generic structure under `modules/nixos/`, including dedicated modules for `desktop` (with `sddm`, `hyprland`, and `home-manager`) and `nix` settings.
  - Centralized host-specific NixOS configuration in `hosts/<host>/config/nixos-config/`.
  - Simplified main host configuration by leveraging the new `nixos-generic.desktop` module, promoting better reusability across different machines.
- **Home Manager:**
  - Improved consistency in module option naming and cleaned up internal comments.
- **Documentation:**
  - Updated `README.md` file tree and feature list to reflect the new NixOS module structure.
  - Added new documentation for NixOS modules in `modules/nixos/README.md`.
  - Refined Homelab architecture diagram to use the unified Prometheus Stack.

## v1.0.16 - 2026-03-18

### Added

- **Homelab:**
  - Integrated `kube-prometheus-stack` for unified monitoring and alerting, replacing the previous standalone `Prometheus` and `Grafana` modules.
  - Added `monitoring` namespace and self-signed HTTPS certificate management for the new Prometheus stack.
- **CI/CD:** Added a `pull_request_template.md` to standardize and improve the contribution workflow.
- **Development:**
  - Added `black` formatter to the Python development module.
  - Added `openssl` to the Zsh package list.

### Changed

- **Documentation:**
  - Updated Homelab architecture diagram and module structure in `modules/homelab/README.md`.
  - Updated main `README.md` file tree and feature list to reflect the new Prometheus stack.

## v1.0.15 - 2026-03-15

### Added

- **Homelab:**
  - Added `Grafana` for data visualization and dashboard management.
  - Integrated self-signed HTTPS certificate management for `Grafana`.

### Changed

- **Homelab:**
  - Corrected `Uptime Kuma` ingress configuration to ensure compatibility with the Helm chart.
- **Documentation:** Updated README files to reflect the latest homelab additions.

## v1.0.14 - 2026-03-12

### Added

- **Homelab:**
  - Added `Uptime Kuma` for service monitoring and status pages.
  - Added `Prometheus` for metrics collection with self-signed HTTPS certificate management.

### Changed

- **Homelab:**
  - Configured `loadBalancerIP` for `Vaultwarden` and `Uptime Kuma` to ensure consistent internal IPs.
  - Enabled `Longhorn` distributed block storage.
- **Networking:** Added `cni0` and `flannel.1` to trusted interfaces in the firewall for improved Kubernetes networking stability.
- **Fixes:** Corrected a label typo (`piihole` -> `pihole`) in the Pi-hole namespace configuration.

## v1.0.13 - 2026-03-10

### Added

- **CI/CD:** Integrated GitHub Actions with `flake-checker` for automated flake health checks.
- **Homelab:** Added self-signed HTTPS certificate management for `Pi-hole` and `Immich`.

### Changed

- **Desktop:**
  - Simplified and refactored `Wofi` configuration and CSS for a cleaner look.
  - Adjusted Hyprland window animations and workspace rules.
  - Updated `Wofi` launch command to toggle visibility (pkill).
- **Homelab:** Minor configuration updates for `Longhorn` and `Prometheus` modules.
- **CI/CD:** Fixed Nix environment availability in GitHub Actions.

## v1.0.12 - 2026-03-08

### Added

- **Spotify:** Added Spotify package and configured autostart in Hyprland.
- **Sioyek:** Added Sioyek, a PDF viewer optimized for technical books and research papers.
- **Host Secrets:** Implemented host-level secrets management using SOPS for the `tsukinara` host, including user password hash management.

### Changed

- **Homelab:** Fixed conditional flags and improved configuration for `cert-manager`, `metallb`, and `vaultwarden`.
- **Security:** Updated user password management to use SOPS-encrypted hashes.
- **Desktop:** Minor updates to Hyprland, Hyprlock, and Wofi configurations.
- **System:** Updated default fonts configuration.
- **Development:** Small tweaks to Git and Tmux configurations.

## v1.0.11 - 2026-03-04

### Changed

- **Configuration Centralization:** Refactored Home Manager and Homelab configurations to be host-specific. This decouples module definitions from their actual configuration, allowing for easier management across different hosts.
- **Home Manager:** Renamed `myHomeConfig` to `homeManager` and moved specific user configurations (apps, desktop, system, hardware) to `hosts/tsukinara/config/home-manager-config/`.
- **Homelab:** Moved homelab service configurations to `hosts/tsukinara/config/homelab-config/`.

## v1.0.10 - 2026-03-04

### Changed

- **Homelab:** Added `enable` flags for `flux`, `databases`, `ingress-nginx`, and `garage` services for more granular control.
- **Ingress-Nginx:** Cleaned up manual manifests to simplify the module structure and transition towards a more managed approach.
- **K3s:** Disabled `k3s` service by default in the host configuration.

## v1.0.9 - 2026-03-03

### Added

- **Disko:** Integrated Disko for declarative disk partitioning and formatting.
- **Immich:** Added Immich, a self-hosted photo and video management solution, to the homelab.
- **QMK:** Added a new QMK module for hardware keyboard configuration.
- **SSH Secrets:** Added SSH secrets management for users and hosts.
- **Prometheus:** Initial module structure added (currently disabled/placeholder).

### Changed

- **K3s:** Updated K3s configuration with improved deployment options.
- **Longhorn:** Explicitly disabled Longhorn due to Helm chart issues affecting flannel generation (see [k3s-io/k3s#13277](https://github.com/k3s-io/k3s/issues/13277#issuecomment-3837472085)).

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

- **Modularized Language Packages:** Implemented modular organization for language-specific-development packages.
- **Added Custom Scripts:** Introduced a collection of useful scripts for various tasks.
- **Git Enhancements:** Added a set of convenient Git aliases and integrated initial Git configuration through Nix.
- **Yaak Integration:** Yaak API client has been added as a Home Manager module.
- **Go Language Server:** Included `gopls` for enhanced Go development experience.
- **README Improvements:** Enhanced README with improved image centering and updated documentation post-tag push.

### Improvements & Fixes

- **Module Reorganization:** Reordered modules for better structural clarity.
- **Configuration Impurity Fixes:** Resolved issues related to impure configuration settings.
- **Dependency Management:** Removed a duplicate GitHub installation and an unused variable.
- **Secrets Management:** Implemented `sops` interpolation for Git configurations.
- **Terminal Experience:** Temporarily disabled Tmux popups and suppressed SSH PID agent number display for a cleaner terminal output.

* **Documentation:** Updated README with feature descriptions and a detailed file tree.

## 2026-01-31

### Resolved sops-nix configuration issues

This session addressed multiple issues related to setting up `sops-nix` for secrets management within the Home Manager configuration.

**Key Changes & Fixes:**

- **`home-manager/security/default.nix` updated:** Corrected an empty file that caused a `syntax error, unexpected end of file`. The file now correctly imports `sops.nix`.
- **`flake.nix` `extraSpecialArgs` configured:** The `sops.nix` module required `settings` and `meta` arguments which were not being passed from `flake.nix`. These arguments, containing `user` and `hostname` information, were added to the `extraSpecialArgs` within the `homeConfigurations` block.
- **`sops.age.keyFile` type clarification:** The `keyFile` option expects a string path, not a list. While the file content was technically correct, the missing `settings` argument masked this, leading to a "cannot coerce a list to a string" error. The explicit passing of `settings` and `meta` resolved the underlying issue.
- **`sops` executable availability:** Ensured the `sops` command-line tool is available in the user's shell by confirming its inclusion in `home.packages` within `home-manager/home.nix`.
- **`secrets.yaml` decryption:** Resolved issues where `sops-nix` failed to decrypt `secrets.yaml` (`Error getting data key: 0 successful groups required, got 0`). This involved ensuring `secrets.yaml` was correctly encrypted with the appropriate AGE public key and contained the expected secret keys as defined in `sops.nix`.
- **`sops.age.sshKeyPaths` management:** Clarified the role and proper configuration of `sops.age.sshKeyPaths` for SSH key-based decryption, addressing potential "Cannot read ssh key" errors.

These changes collectively enabled the successful evaluation and activation of the `sops-nix` service, allowing for secure management of secrets.

