{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [./qmk];
  options.myHomeConfig.hardware = {
    enable = lib.mkEnableOption "hardware options";
    qmk = {
      enable = lib.mkEnableOption "qmk module";
    };
  };

  config = lib.mkIf config.myHomeConfig.hardware.enable {
    qmk.enable = lib.mkDefault config.myHomeConfig.qmk.enable;
  };
}
