{ pkgs, lib, config, ... }: {
  options = { git.enable = lib.mkEnableOption "Enable git module"; };

  config = lib.mkIf config.myHomeConfig.apps.development.terminal.git.enable {
    programs.git = {
      enable = true;
      lfs = { enable = true; };
      settings = {
        user = {
          #TODO: Fix this impurity
          name = builtins.readFile config.sops.secrets.depaysementGitName.path;
          email = builtins.readFile config.sops.secrets.depaysementEmail.path;
        };
        core = {
          editor = "nvim";
          sshCommand = "ssh -i ~/.ssh/tsukinara_ed25519 -o IdentitiesOnly=yes";
        };
        alias = {
          co = "checkout";
          s = "stash -u";
          br = "branch";
          cm = "commit";
          st = "status";
          lg = "log --oneline --graph --all";
        };
        init = { defaultBranch = "develop"; };
        branch = { autoSetupRemote = true; };
        fetch = { prune = true; };
        maintenance.repo = "${config.home.homeDirectory}/.nixos-dotfiles";
        safe.directory = "${config.home.homeDirectory}/.nixos-dotfiles";
      };
    };
    home.packages = with pkgs; [ gh ];
  };
}
