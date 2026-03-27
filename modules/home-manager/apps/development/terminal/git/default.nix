{
  pkgs,
  lib,
  config,
  settings,
  ...
}: {
  options = {git.enable = lib.mkEnableOption "Enable git module";};

  config = lib.mkIf config.homeManager.apps.development.terminal.git.enable {
    programs.git = {
      enable = true;
      lfs = {enable = true;};
      settings = {
        core = {
          editor = "nvim";
          sshCommand = "ssh -i ~/.ssh/${settings.user} -o IdentitiesOnly=yes";
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
        gpg = {
          format = "ssh";
          ssh = {
            allowedSignersFile = "/home/${settings.user}/.config/git/allowed-signers";
          };
        };
        commit = {
          gpgsign = true;
        };
        init = {defaultBranch = "develop";};
        push = {autoSetupRemote = true;};
        fetch = {prune = true;};
        maintenance.repo = "${config.home.homeDirectory}/.nixos-dotfiles";
        safe.directory = "${config.home.homeDirectory}/.nixos-dotfiles";
      };
      includes = [{path = "user.gitconfig";}];
    };
    home.packages = with pkgs; [gh];
  };
}
