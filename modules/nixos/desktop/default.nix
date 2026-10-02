{
  lib,
  config,
  ...
}: let
  cfg = config.nixos-generic.desktop;
in {
  imports = [./sddm ./hyprland ./home-manager ./audio ./tuigreet ./openLinkHub];
  options.nixos-generic.desktop = {
    enable = lib.mkEnableOption "Desktop environment";
  };

  config = lib.mkIf cfg.enable {
    services.upower.enable = true;
    nixos-generic.desktop = {
      sddm.enable = lib.mkDefault true;
      tuigreet.enable = lib.mkDefault true;
      hyprland.enable = lib.mkDefault true;
      homeManager.enable = lib.mkDefault true;
      audio.enable = lib.mkDefault true;
      openLinkHub.enable = lib.mkDefault true;
    };
  };
}
