{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {ghostty.enable = lib.mkEnableOption "Enable ghostty module";};
  config = lib.mkIf config.myHomeConfig.apps.development.terminal.ghostty.enable {
    home.packages = with pkgs; [ghostty];
  };
}
