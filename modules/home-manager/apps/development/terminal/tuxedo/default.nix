{
  lib,
  config,
  pkgs,
  ...
}: {
  options.tuxedo.enable = lib.mkEnableOption "Enable tuxedo module";

  config = lib.mkIf config.homeManager.apps.development.terminal.tuxedo.enable {
    home.packages = with pkgs; [tuxedo];
  };
}
