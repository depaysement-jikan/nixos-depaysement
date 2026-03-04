{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {ghostty.enable = lib.mkEnableOption "Enable ghostty module";};
  config = lib.mkIf config.homeManager.apps.development.terminal.ghostty.enable {
    home.packages = with pkgs; [ghostty];
  };
}
