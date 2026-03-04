{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [./qmk];
  options.homeManager.hardware = {
    enable = lib.mkEnableOption "hardware options";
    qmk = {
      enable = lib.mkEnableOption "qmk module";
    };
  };

  config = lib.mkIf config.homeManager.hardware.enable {
    qmk.enable = lib.mkDefault config.homeManager.qmk.enable;
  };
}
