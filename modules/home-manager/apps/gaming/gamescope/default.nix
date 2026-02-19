{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {gamescope.enable = lib.mkEnableOption "Enable gamescope module";};
  config = lib.mkIf config.myHomeConfig.apps.gaming.gamescope.enable {
    home.packages = with pkgs; [gamescope];
  };
}
