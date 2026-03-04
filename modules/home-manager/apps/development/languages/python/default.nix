{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {python.enable = lib.mkEnableOption "Enable python module";};
  config = lib.mkIf config.homeManager.apps.development.languages.python.enable {
    home.packages = with pkgs; [python3 uv pyright];
  };
}
