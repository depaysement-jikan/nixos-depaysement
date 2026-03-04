{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {firefox.enable = lib.mkEnableOption "Enable firefox module";};
  config = lib.mkIf config.homeManager.apps.browsers.firefox.enable {
    home.packages = with pkgs; [firefox];
  };
}
