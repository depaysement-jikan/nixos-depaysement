{ lib, config, ... }: {
  imports = [ ./catppuccin ];

  options = { themes.enable = lib.mkEnableOption "Enable themes module"; };
  config =
    lib.mkIf config.browsers.enable { catppuccin.enable = lib.mkDefault true; };
}
