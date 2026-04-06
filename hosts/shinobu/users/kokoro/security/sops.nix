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
      sshKeyPaths = ["/var/lib/sops-nix/.ssh/kokoro"];
      # Instructions:
      # mkdir -p /var/lib/sops-nix/age
      # age-keygen -o /var/lib/sops-nix/age/keys.txt
      # Fill in your secrets in YAML format
      # sudo sops --encrypt  --in-place --age $(sudo age-keygen -y /var/lib/sops-nix/age/key.txt) ~/.nixos-dotfiles/hosts/shinobu/users/kokoro/secrets.yaml
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
    };
    templates.git-user = {
      path = "/home/kokoro/.config/git/user.gitconfig";
      mode = "0644";
      owner = "kokoro";
      content = ''
        [user]
          name = ${config.sops.placeholder.userGitName}
          email = ${config.sops.placeholder.userGitEmail}
      '';
    };
  };
}
