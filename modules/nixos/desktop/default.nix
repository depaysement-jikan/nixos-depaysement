{
  lib,
  config,
  ...
}: let
  cfg = config.nixos-generic.desktop;
in {
  imports = [./sddm ./hyprland ./home-manager];
  options.nixos-generic.desktop = {
    enable = lib.mkEnableOption "Desktop environment";
  };

  config = lib.mkIf cfg.enable {
    nixos-generic.desktop = {
      sddm.enable = lib.mkDefault true;
      hyprland.enable = lib.mkDefault true;
      homeManager.enable = lib.mkDefault true;
    };
  };
}
