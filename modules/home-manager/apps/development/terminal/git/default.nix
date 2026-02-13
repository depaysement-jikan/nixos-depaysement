{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {git.enable = lib.mkEnableOption "Enable git module";};

  config = lib.mkIf config.myHomeConfig.apps.development.terminal.git.enable {
    programs.git = {
      enable = true;
      lfs = {enable = true;};
      settings = {
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
          cp = "cherry-pick";
          adda = "add -A";
        };
        init = {defaultBranch = "develop";};
        branch = {autoSetupRemote = true;};
        fetch = {prune = true;};
        maintenance.repo = "${config.home.homeDirectory}/.nixos-dotfiles";
        safe.directory = "${config.home.homeDirectory}/.nixos-dotfiles";
      };
      includes = [{path = config.sops.templates.git-user.path;}];
    };
    home.packages = with pkgs; [gh];
  };
}
