{ meta, settings, inputs, pkgs, ... }: {
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  home = { packages = with pkgs; [ age sops ]; };

  sops = {
    defaultSopsFile = ../secrets.yaml;
    age = {
      sshKeyPaths = [ "/home/${settings.user}/.ssh/${meta.hostname}_ed25519" ];
      # Instructions:
      # mkdir -p ~/.config/sops/age
      # age-keygen -o ~/.config/sops/age/keys.txt
      # mkdir ~/.nixos-dotfiles/home-manager/secrets.yaml
      # Fill in your secrets in YAML format
      # sops --encrypt  --in-place --age $(age-keygen -y ~/.config/sops/age/keys.txt) ~/.nixos-dotfiles/home-manager/secrets.yaml
      # home-manager switch --flake .
      keyFile = "/home/${settings.user}/.config/sops/age/keys.txt";
    };
    secrets = {
      depaysementPassword = { };
      depaysementGitUserName = { };
      depaysementEmail = { };
      depaysementGitName = { };
    };
  };
}
