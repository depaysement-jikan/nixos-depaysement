{ lib, config, ... }:
let cfg = config.myHomeConfig.desktop;
in {
  imports = [ ./rofi ./hyprland ./wofi ];

  options.myHomeConfig.desktop = {
    enable = lib.mkEnableOption "Desktop environment";
    rofi.enable = lib.mkEnableOption "Rofi launcher";
    wofi.enable = lib.mkEnableOption "Wofi launcher";
    hyprland.enable = lib.mkEnableOption "hyprland launcher";
  };

  config = lib.mkIf cfg.enable {
    rofi.enable = lib.mkDefault cfg.rofi.enable;
    wofi.enable = lib.mkDefault cfg.wofi.enable;
    hyprland.enable = lib.mkDefault cfg.hyprland.enable;
  };
}
