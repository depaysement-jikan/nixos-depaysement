{ lib, config, ... }:
let cfg = config.myHomeConfig.desktop;
in {
  imports = [ ./rofi ./hyprland ];

  options.myHomeConfig.desktop = {
    enable = lib.mkEnableOption "Desktop environment";
    rofi.enable = lib.mkEnableOption "Rofi launcher";
    hyprland.enable = lib.mkEnableOption "hyprland launcher";
  };

  config = lib.mkIf cfg.enable {
    rofi.enable = lib.mkDefault cfg.rofi.enable;
    hyprland.enable = lib.mkDefault cfg.hyprland.enable;
  };
}
