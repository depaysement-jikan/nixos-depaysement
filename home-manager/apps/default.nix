{ lib, config, ... }:
let cfg = config.myHomeConfig.apps;
in {
  imports = [ ./browsers ];

  options.myHomeConfig.apps = {
    enable = lib.mkEnableOption "applications and GUI programs";
    browsers.enable = lib.mkEnableOption "web browsers";
  };

  config = lib.mkIf cfg.enable {
    browsers.enable = lib.mkDefault cfg.browsers.enable;
  };
}
