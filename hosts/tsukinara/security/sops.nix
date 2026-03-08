{
  meta,
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  environment.systemPackages = builtins.attrValues {inherit (pkgs) age sops;};

  sops = {
    age = {
      sshKeyPaths = ["/var/lib/sops-nix/.ssh/${meta.hostname}"];
      # Instructions:
      # mkdir -p ~/.config/sops/age
      # age-keygen -o ~/.config/sops/age/keys.txt
      # mkdir ~/.nixos-dotfiles/home-manager/secrets.yaml
      # Fill in your secrets in YAML format
      # sudo sops --encrypt  --in-place --age $(sudo age-keygen -y /var/lib/sops-nix/age/key.txt) ~/.nixos-dotfiles/hosts/tsukinara/secrets.yaml
      # home-manager switch --flake .
      keyFile = "/var/lib/sops-nix/age/key.txt";
    };
    secrets = {
      depaysementUserPassword = {
        sopsFile = ../secrets.yaml;
      };
    };
  };
}
