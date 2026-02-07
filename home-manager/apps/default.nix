{ lib, config, ... }:
let cfg = config.myHomeConfig.apps;
in {
  imports = [ ./browsers ./web ./development ];

  options.myHomeConfig.apps = {
    enable = lib.mkEnableOption "applications and GUI programs";
    browsers.enable = lib.mkEnableOption "web browsers";
    web.enable = lib.mkEnableOption "web apps";
    development = {
      enable = lib.mkEnableOption "development configuration";
      terminal = {
        enable = lib.mkEnableOption "terminal configuration";
        yazi.enable = lib.mkEnableOption "yazi configuration";
        zsh.enable = lib.mkEnableOption "zsh configuration";
        tmux.enable = lib.mkEnableOption "tmux configuration";
        git.enable = lib.mkEnableOption "git configuration";
        ghostty.enable = lib.mkEnableOption "ghostty configuration";
        neovim.enable = lib.mkEnableOption "ghostty configuration";
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
    };
  };

  config = lib.mkIf cfg.enable {
    browsers.enable = lib.mkDefault cfg.browsers.enable;
    web.enable = lib.mkDefault cfg.web.enable;
    development.enable = lib.mkDefault cfg.development.enable;
  };
}
