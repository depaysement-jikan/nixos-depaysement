{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.myHomeConfig.desktop.rofi;
in {
  options = {rofi.enable = lib.mkEnableOption "Enable Rofi";};

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [rofi rofi-emoji];
    programs.rofi = {enable = true;};
  };
}
