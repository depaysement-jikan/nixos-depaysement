{
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  environment.systemPackages = builtins.attrValues {inherit (pkgs) age sops;};

  sops = {
    age = {
      sshKeyPaths = ["/var/lib/sops-nix/.ssh/depaysement"];
      # Instructions:
      # mkdir -p /var/lib/sops-nix/age
      # age-keygen -o /var/lib/sops-nix/age/keys.txt
      # Fill in your secrets in YAML format
      # sudo sops --encrypt  --in-place --age $(sudo age-keygen -y /var/lib/sops-nix/age/key.txt) ~/.nixos-dotfiles/hosts/tsukinara/users/depaysement/secrets.yaml
      # sudo nixos-rebuild switch --flake .#tsukinara
      keyFile = "/var/lib/sops-nix/age/key.txt";
    };
    secrets = {
      userHashedPassword = {
        neededForUsers = true;
        sopsFile = ../secrets.yaml;
      };
      userGitName = {
        sopsFile = ../secrets.yaml;
      };
      userGitEmail = {
        sopsFile = ../secrets.yaml;
      };
      userPublicSshKey = {
        sopsFile = ../secrets.yaml;
      };
    };
    templates.git-user = {
      path = "/home/depaysement/.config/git/user.gitconfig";
      mode = "0644";
      owner = "depaysement";
      content = ''
        [user]
          name = ${config.sops.placeholder.userGitName}
          email = ${config.sops.placeholder.userGitEmail}
          signingkey = "/home/depaysement/.ssh/depaysement.pub";
      '';
    };
    templates.allowed-signers = {
      path = "/home/depaysement/.config/git/allowed-signers";
      mode = "0644";
      owner = "depaysement";
      content = ''
        ${config.sops.placeholder.userGitEmail} ${config.sops.placeholder.userPublicSshKey}
      '';
    };
  };
}
