# Homelab Configuration

This directory contains the configuration for the homelab, which is built on top of a Kubernetes cluster managed by k3s. The entire setup is declarative, using Nix to define and configure all the services.

## Structure

The homelab is composed of several modules, each responsible for a specific part of the infrastructure:

-   **`k3s/`**: The core Kubernetes setup.
-   **`flux/`**: Manages the GitOps workflow, keeping the cluster state in sync with the configuration in this repository.
-   **`security/`**: Handles secrets management for the homelab services using `sops-nix`.
-   **`services/`**: Defines the various services running in the homelab.
-   **`rclone/`**: Configures `rclone` for backups and syncing.
-   **`ingress-nginx/`**: Manages ingress traffic to the services.
-   **`vaultwarden/`**: A self-hosted password manager.
-   **`cert-manager/`**: Automates the management of TLS certificates.
-   **`garage/`**: A self-hosted Git server.
-   **`databases/`**: Manages the databases used by the services.
-   **`metallb/`**: Provides load-balancing for the services.
-   **`pihole/`**: A network-wide ad-blocker.

The main entry point is `default.nix`, which imports all the modules and configures them.
