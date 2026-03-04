{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {crush.enable = lib.mkEnableOption "Enable crush module";};
  config = lib.mkIf config.homeManager.apps.development.ai.crush.enable {
    home.packages = with pkgs; [crush];
  };
}
