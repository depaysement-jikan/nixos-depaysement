{
  lib,
  config,
  ...
}: let
  cfg = config.homeManager.system;
in {
  imports = [./fonts ./themes ./clipboard ./openLinkHub];

  options.homeManager.system = {
    enable = lib.mkEnableOption "system configuration and utilities";
    fonts.enable = lib.mkEnableOption "fonts configuration";
    openLinkHub.enable = lib.mkEnableOption "openLinkHub configuration";
    themes = {
      enable = lib.mkEnableOption "themes configuration";
      catppuccin.enable = lib.mkEnableOption "Catppuccin configuration";
      stylix.enable = lib.mkEnableOption "Stylix configuration";
    };
    clipboard.enable = lib.mkEnableOption "Clipboard configuration";
  };

  config = lib.mkIf cfg.enable {
    fonts.enable = lib.mkDefault cfg.fonts.enable;
    openLinkHub.enable = lib.mkDefault cfg.openLinkHub.enable;
    themes.enable = lib.mkDefault cfg.themes.enable;
    clipboard.enable = lib.mkDefault cfg.themes.enable;
  };
}
