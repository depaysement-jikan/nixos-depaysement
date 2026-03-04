{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {go.enable = lib.mkEnableOption "Enable go module";};
  config = lib.mkIf config.homeManager.apps.development.languages.go.enable {
    home.packages = with pkgs; [go gopls];
  };
}
