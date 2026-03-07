{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {spotify.enable = lib.mkEnableOption "enable spotify module";};
  config = lib.mkIf config.homeManager.apps.social.spotify.enable {
    home.packages = with pkgs; [
      spotify
    ];
  };
}
