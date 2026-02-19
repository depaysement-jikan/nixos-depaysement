{
  lib,
  config,
  ...
}: {
  imports = [./steam ./gamescope];

  options = {gaming.enable = lib.mkEnableOption "Enable gaming module";};
  config = lib.mkIf config.gaming.enable {
    steam.enable = lib.mkDefault true;
    gamescope.enable = lib.mkDefault true;
  };
}
