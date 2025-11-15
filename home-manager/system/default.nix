{ lib, config, ... }:
let cfg = config.myHomeConfig.system;
in {
  imports = [ ./fonts ./theme ];

  options.myHomeConfig.system = {
    enable = lib.mkEnableOption "system configuration and utilities";
    fonts.enable = lib.mkEnableOption "fonts configuration";
    theme.enable = lib.mkEnableOption "theme configuration";
  };

  config = lib.mkIf cfg.enable {
    fonts.enable = lib.mkDefault cfg.fonts.enable;
    theme.enable = lib.mkDefault cfg.theme.enable;
  };
}
