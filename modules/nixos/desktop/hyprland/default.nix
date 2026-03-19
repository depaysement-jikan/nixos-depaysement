{
  config,
  lib,
  ...
}: {
  options.nixos-generic.desktop.hyprland.enable = lib.mkEnableOption "hyprland";
  config = lib.mkIf config.nixos-generic.desktop.hyprland.enable {
    programs.hyprland.enable = true;
  };
}
