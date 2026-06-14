{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {doppler.enable = lib.mkEnableOption "Enable doppler module";};
  config = lib.mkIf config.homeManager.apps.development.terminal.doppler.enable {
    home.packages = with pkgs; [doppler];
  };
}
