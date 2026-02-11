{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    typescript.enable = lib.mkEnableOption "Enable typescript module";
  };
  config = lib.mkIf config.myHomeConfig.apps.development.languages.typescript.enable {
    home.packages = with pkgs; [typescript-language-server typescript];
  };
}
