{
  lib,
  config,
  ...
}: {
  imports = [./catppuccin ./stylix];

  options = {themes.enable = lib.mkEnableOption "Enable themes module";};
  config = lib.mkIf config.themes.enable {
    catppuccin.enable = lib.mkDefault true;
    stylix.enable = lib.mkDefault true;
  };
}
