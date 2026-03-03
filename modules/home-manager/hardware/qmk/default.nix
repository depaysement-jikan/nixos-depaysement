{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {qmk.enable = lib.mkEnableOption "Enable qmk module";};
  config = lib.mkIf config.myHomeConfig.hardware.qmk.enable {
    home.packages = with pkgs; [qmk];
  };
}
