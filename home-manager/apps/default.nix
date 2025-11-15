{ lib, config, ... }:
let cfg = config.myHomeConfig.apps;
in {
  imports = [ ./browsers ./web ];

  options.myHomeConfig.apps = {
    enable = lib.mkEnableOption "applications and GUI programs";
    browsers.enable = lib.mkEnableOption "web browsers";
    web.enable = lib.mkEnableOption "web apps";
  };

  config = lib.mkIf cfg.enable {
    browsers.enable = lib.mkDefault cfg.browsers.enable;
    web.enable = lib.mkDefault cfg.web.enable;
  };
}
