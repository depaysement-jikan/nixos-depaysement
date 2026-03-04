{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {c.enable = lib.mkEnableOption "Enable c module";};
  config = lib.mkIf config.homeManager.apps.development.languages.c.enable {
    home.packages = with pkgs; [clang-tools gcc];
  };
}
