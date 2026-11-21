{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {typst.enable = lib.mkEnableOption "Enable typst module";};
  config = lib.mkIf config.homeManager.apps.development.languages.typst.enable {
    home.packages = with pkgs; [typst typstyle tinymist];
  };
}
