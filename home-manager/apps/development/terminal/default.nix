{ lib, config, ... }: {
  imports = [ ./yazi ];

  options = { terminal.enable = lib.mkEnableOption "Enable terminal module"; };
  config = lib.mkIf config.myHomeConfig.apps.development.terminal.enable {
    yazi.enable = lib.mkDefault true;
  };
}
