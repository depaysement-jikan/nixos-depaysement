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
      };
    };
  };

  config = lib.mkIf cfg.enable {
    browsers.enable = lib.mkDefault cfg.browsers.enable;
    web.enable = lib.mkDefault cfg.web.enable;
    development.enable = lib.mkDefault cfg.development.enable;
  };
}
