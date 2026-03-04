{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {lua.enable = lib.mkEnableOption "Enable lua module";};
  config = lib.mkIf config.homeManager.apps.development.languages.lua.enable {
    home.packages = with pkgs; [lua-language-server stylua];
  };
}
