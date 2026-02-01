# ~/.nixos-dotfiles

<p align="center">
  <img src="home-manager/pfp/sachi.webp" style="width:300px; height:auto;"/>
</p>

My personal [NixOS](https://nixos.org/) configuration, managed with [Nix Flakes](https://nixos.wiki/wiki/Flakes).

## ✨ Showcase

_Coming soon..._

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

### Secrets Management with `sops-nix`

This configuration leverages [`sops-nix`](https://github.com/Mic92/sops-nix) to securely manage sensitive data like API tokens, passwords, and other secrets within your declarative Home Manager setup. Secrets are encrypted in your Git repository and decrypted only at activation time on your local machine.

#### How it Works

1.  **Secret Definition (`home-manager/security/sops.nix`):**
    - The `sops` configuration block defines which secrets to manage and how they should be handled.
    - Each secret, like `depaysementPassword`, is declared, and `sops-nix` expects to find its encrypted value in the `secrets.yaml` file.

2.  **Key Configuration:**
    - `sops-nix` uses AGE keys (or SSH keys) for encryption and decryption. You need to configure at least one key source.
    - `sops.age.keyFile`: Specifies the path to your AGE private key (e.g., `/home/depaysement/.config/sops/age/keys.txt`).
    - `sops.age.sshKeyPaths`: (Optional) Specifies a list of paths to SSH private keys that can be used as AGE keys.

3.  **`secrets.yaml` (Encrypted Secrets File):**
    - The `sops.defaultSopsFile` option points to your encrypted secrets file (e.g., `../../secrets.yaml`, which resolves to the project root's `secrets.yaml`).
    - This file contains your actual secrets in an encrypted format.

4.  **`flake.nix` `extraSpecialArgs`:**
    - The `sops.nix` module relies on `settings` and `meta` arguments (which are custom to this configuration) to construct paths for keys and other user-specific configurations.
    - These arguments (`settings.user` for your username and `meta.hostname` for your machine's hostname) are passed via `extraSpecialArgs` in your `flake.nix` to ensure the `sops.nix` module receives the correct context for path generation.

#### Setup Instructions

To get `sops-nix` working and manage your secrets:

1.  **Ensure `sops` and `age` are installed:**
    Make sure `pkgs.sops` and `pkgs.age` are included in your `home.packages` list in `home-manager/home.nix`. After a successful `home-manager switch`, these tools will be available in your shell.

2.  **Generate an AGE private key (if you don't have one):**
    This key is crucial for decrypting your secrets. Store it securely and _do not_ commit it to Git.

    ```bash
    mkdir -p ~/.config/sops/age
    age-keygen -o ~/.config/sops/age/keys.txt
    ```

    **Important:** Back up this `keys.txt` file immediately! Losing it means permanent loss of access to your encrypted secrets.

3.  **Get your AGE public key:**
    You'll use this public key to encrypt your `secrets.yaml` file.

    ```bash
    age-keygen -y ~/.config/sops/age/keys.txt
    ```

    Copy the output (a string starting with `age1...`). This is your public key.

4.  **Create or encrypt your `secrets.yaml` file:**
    If you have an existing plain-text `secrets.yaml` (e.g., at `/home/depaysement/.nixos-dotfiles/secrets.yaml`), you can encrypt it in-place. If you're creating it from scratch, you can provide the content directly.
    - **Encrypting an existing plain-text `secrets.yaml` in-place:**
      Ensure your `secrets.yaml` file contains the plain-text secrets you wish to encrypt. For example:

      ```yaml
      depaysementPassword: your_actual_password
      depaysementGitUserName: your_github_username
      depaysementEmail: your_email@example.com
      depaysementGitName: Your Name
      ```

      Then run the encryption command:

      ```bash
      sops --encrypt --age "YOUR_AGE_PUBLIC_KEY" --in-place /home/depaysement/.nixos-dotfiles/secrets.yaml
      ```

      (Replace `"YOUR_AGE_PUBLIC_KEY"` with the public key from step 3).

    - **Creating a new, encrypted `secrets.yaml`:**
      ```bash
      sops --encrypt --age "YOUR_AGE_PUBLIC_KEY" /home/depaysement/.nixos-dotfiles/secrets.yaml <<EOF
      depaysementPassword: your_actual_password
      depaysementGitUserName: your_github_username
      depaysementEmail: your_email@example.com
      depaysementGitName: Your Name
      EOF
      ```
      (Replace `"YOUR_AGE_PUBLIC_KEY"` and the example values with your actual data).

5.  **Run Home Manager Switch:**
    After your `secrets.yaml` is correctly encrypted and your keys are in place, apply your Home Manager configuration:
    ```bash
    home-manager switch --flake .#depaysement@tsukinara
    ```
    This will activate the `sops-nix` service, which will decrypt and manage your secrets.

## 🙏 Credits

This configuration is inspired by the many amazing dotfiles repositories in the NixOS community.
