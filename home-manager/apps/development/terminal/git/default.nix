{ pkgs, lib, config, ... }: {
  options = { git.enable = lib.mkEnableOption "Enable git module"; };

  config = lib.mkIf config.myHomeConfig.apps.development.terminal.git.enable {
    programs.git = {
      enable = true;
      lfs = { enable = true; };
      settings = {
        user = {
          #TODO: Fix this impurity
          name = { sopsFile = config.sops.secrets.depaysementGitName; };
          email = { sopsFile = config.sops.secrets.depaysementEmail; };
        };
        core = {
          editor = "nvim";
          sshCommand = "ssh -i ~/.ssh/tsukinara_ed25519 -o IdentitiesOnly=yes";
        };
        init = { defaultBranch = "develop"; };
        branch = { autoSetupRemote = true; };
        fetch = { prune = true; };
        maintenance.repo = "${config.home.homeDirectory}/.nixos-dotfiles";
        safe.directory = "${config.home.homeDirectory}/.nixos-dotfiles";
      };
    };
    home.packages = with pkgs; [ gh git ];
  };
}
