{
  lib,
  config,
  ...
}: let
  cfg = config.myHomeConfig.apps;
in {
  imports = [./browsers ./social ./development ./productivity ./gaming];

  options.myHomeConfig.apps = {
    enable = lib.mkEnableOption "applications and GUI programs";
    browsers = {
      enable = lib.mkEnableOption "web browsers";
      zen.enable = lib.mkEnableOption "zen configuration";
      firefox.enable = lib.mkEnableOption "firefox configuration";
      floorp.enable = lib.mkEnableOption "floorp configuration";
    };
    social = {
      enable = lib.mkEnableOption "social apps";
      discord.enable = lib.mkEnableOption "discord configuration";
      whatsapp.enable = lib.mkEnableOption "whatsapp configuration";
    };
    gaming = {
      enable = lib.mkEnableOption "gaming apps";
      steam.enable = lib.mkEnableOption "steam configuration";
      gamescope.enable = lib.mkEnableOption "gamescope configuration";
    };
    productivity = {
      enable = lib.mkEnableOption "productivity apps";
      obsidian.enable = lib.mkEnableOption "obsidian configuration";
    };
    development = {
      enable = lib.mkEnableOption "development configuration";
      terminal = {
        enable = lib.mkEnableOption "terminal configuration";
        yazi.enable = lib.mkEnableOption "yazi configuration";
        zsh.enable = lib.mkEnableOption "zsh configuration";
        nushell.enable = lib.mkEnableOption "nushell configuration";
        tmux.enable = lib.mkEnableOption "tmux configuration";
        git.enable = lib.mkEnableOption "git configuration";
        ghostty.enable = lib.mkEnableOption "ghostty configuration";
        neovim.enable = lib.mkEnableOption "ghostty configuration";
        starship.enable = lib.mkEnableOption "starship configuration";
      };
      api-clients = {
        enable = lib.mkEnableOption "api-clients configuration";
        yaak.enable = lib.mkEnableOption "yaak configuration";
      };
      languages = {
        enable = lib.mkEnableOption "languages configuration";
        go.enable = lib.mkEnableOption "go configuration";
        node.enable = lib.mkEnableOption "node configuration";
        markdown.enable = lib.mkEnableOption "markdown configuration";
        nix-lang.enable = lib.mkEnableOption "nix configuration";
        sh.enable = lib.mkEnableOption "sh configuration";
        c.enable = lib.mkEnableOption "c configuration";
        typescript.enable = lib.mkEnableOption "typescript configuration";
        lua.enable = lib.mkEnableOption "lua configuration";
        python.enable = lib.mkEnableOption "python configuration";
        rust.enable = lib.mkEnableOption "rust configuration";
      };
      ai = {
        enable = lib.mkEnableOption "ai configuration";
        crush.enable = lib.mkEnableOption "crush configuration";
      };
      db = {
        enable = lib.mkEnableOption "db configuration";
        postgres.enable = lib.mkEnableOption "postgres configuration";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    browsers.enable = lib.mkDefault cfg.browsers.enable;
    development.enable = lib.mkDefault cfg.development.enable;
    productivity.enable = lib.mkDefault cfg.productivity.enable;
    social.enable = lib.mkDefault cfg.social.enable;
    gaming.enable = lib.mkDefault cfg.gaming.enable;
  };
}
