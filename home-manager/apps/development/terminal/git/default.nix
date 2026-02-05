{ pkgs, lib, config, settings, ... }: {
  options = { git.enable = lib.mkEnableOption "Enable git module"; };

  config = lib.mkIf config.myHomeConfig.apps.development.terminal.git.enable {
    programs.git = {
      enable = true;
      lfs = { enable = true; };
      settings = {
        user = {
          # name = "cat ${config.sops.secrets.depaysementName.path}";
          # email = "cat ${config.sops.secrets.depaysementEmail.path}";
          name = "test";
          email = "test@test.com";
        };
        core = { editor = "nvim"; };
        init = { defaultBranch = "main"; };
        branch = { autoSetupRemote = true; };
        fetch = { prune = true; };
        maintenance.repo = "/home/${settings.user}/.nixos-dotfiles";
        safe = { directory = "/home/${settings.user}/.nixos-dotfiles"; };
      };
    };
    home.packages = with pkgs; [ gh git ];
  };
}
