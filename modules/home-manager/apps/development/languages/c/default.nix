{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {c.enable = lib.mkEnableOption "Enable c module";};
  config = lib.mkIf config.myHomeConfig.apps.development.languages.c.enable {
    home.packages = with pkgs; [clang-tools gcc];
  };
}
