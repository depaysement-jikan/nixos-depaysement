{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {crush.enable = lib.mkEnableOption "Enable crush module";};
  config = lib.mkIf config.myHomeConfig.apps.development.ai.crush.enable {
    home.packages = with pkgs; [crush];
  };
}
