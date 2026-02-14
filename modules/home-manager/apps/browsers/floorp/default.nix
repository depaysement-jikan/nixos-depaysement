{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {floorp.enable = lib.mkEnableOption "Enable floorp module";};
  config = lib.mkIf config.myHomeConfig.apps.browsers.floorp.enable {
    home.packages = with pkgs; [floorp-bin];
  };
}
