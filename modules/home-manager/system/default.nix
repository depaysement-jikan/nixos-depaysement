{
  lib,
  config,
  ...
}: let
  cfg = config.myHomeConfig.system;
in {
  imports = [./fonts ./themes];

  options.myHomeConfig.system = {
    enable = lib.mkEnableOption "system configuration and utilities";
    fonts.enable = lib.mkEnableOption "fonts configuration";
    themes = {
      enable = lib.mkEnableOption "themes configuration";
      catppuccin.enable = lib.mkEnableOption "Catppuccin configuration";
      stylix.enable = lib.mkEnableOption "Stylix configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    fonts.enable = lib.mkDefault cfg.fonts.enable;
    themes.enable = lib.mkDefault cfg.themes.enable;
  };
}
