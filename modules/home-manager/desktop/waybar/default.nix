{
  lib,
  config,
  pkgs,
  ...
}: let
  transparentConfig = import ./transparent/config.nix {inherit config lib;};
  transparentStyle = import ./transparent/style.nix {inherit config lib;};
in {
  options = {waybar.enable = lib.mkEnableOption "Enable waybar module";};
  config = {
    programs.waybar = {
      enable = config.waybar.enable;
      package = pkgs.waybar;
      settings = transparentConfig;
      style = transparentStyle;
      systemd = {enable = config.waybar.enable;};
    };
  };
}
