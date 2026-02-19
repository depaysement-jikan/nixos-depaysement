{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {steam.enable = lib.mkEnableOption "Enable steam module";};

  config = lib.mkIf config.myHomeConfig.apps.gaming.steam.enable {
    home.packages = with pkgs; [steam gamemode];
  };
}
