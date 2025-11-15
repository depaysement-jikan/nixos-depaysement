{ pkgs, lib, config, ... }: {
  options = { rofi.enable = lib.mkEnableOption "Enable rofi"; };

  config = lib.mkIf config.rofi.enable {
    home.packages = with pkgs; [ rofi rofi-emoji ];
  };
}
