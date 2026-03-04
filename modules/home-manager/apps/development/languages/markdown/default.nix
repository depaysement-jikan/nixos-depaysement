{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {markdown.enable = lib.mkEnableOption "Enable markdown module";};
  config = lib.mkIf config.homeManager.apps.development.languages.markdown.enable {
    home.packages = with pkgs; [marksman];
  };
}
