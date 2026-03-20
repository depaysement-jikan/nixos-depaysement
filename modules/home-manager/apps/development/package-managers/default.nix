{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {package-managers.enable = lib.mkEnableOption "Enable package managers module";};
  config = lib.mkIf config.homeManager.apps.development.package-managers.enable {
    home.packages = with pkgs; [wget];
  };
}
