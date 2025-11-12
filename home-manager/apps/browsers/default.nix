{ lib, config, ... }: {
  imports = [ ./zen ];

  options = { browsers.enable = lib.mkEnableOption "Enable browsers module"; };
  config = lib.mkIf config.browsers.enable { zen.enable = lib.mkDefault true; };
}
