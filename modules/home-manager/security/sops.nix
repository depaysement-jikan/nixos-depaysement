{
  meta,
  settings,
  inputs,
  pkgs,
  config,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  home = {packages = with pkgs; [age sops];};

  sops = {
    defaultSopsFile = ../secrets.yaml;
    age = {
      sshKeyPaths = ["/home/${settings.user}/.ssh/${meta.hostname}_ed25519"];
      # Instructions:
      # mkdir -p ~/.config/sops/age
      # age-keygen -o ~/.config/sops/age/keys.txt
      # mkdir ~/.nixos-dotfiles/home-manager/secrets.yaml
      # Fill in your secrets in YAML format
      # sops --encrypt  --in-place --age $(age-keygen -y ~/.config/sops/age/keys.txt) ~/.nixos-dotfiles/modules/homelab/secrets.yaml
      # home-manager switch --flake .
      keyFile = "/home/${settings.user}/.config/sops/age/keys.txt";
    };
    secrets = {
      depaysementPassword = {};
      depaysementGitUserName = {};
      depaysementEmail = {};
      depaysementGitName = {};
    };

    templates.git-user = {
      path = "${config.home.homeDirectory}/.config/git/user.gitconfig";
      mode = "0400";
      content = ''
        [user]
          name = ${config.sops.placeholder.depaysementGitName}
          email = ${config.sops.placeholder.depaysementEmail}
      '';
    };
  };
}
