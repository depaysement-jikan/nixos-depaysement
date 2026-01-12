{ lib, config, ... }: {
  imports = [ ./terminal ];

  options = {
    development.enable = lib.mkEnableOption "Enable development module";
  };
  config = lib.mkIf config.development.enable {
    terminal.enable = lib.mkDefault true;
  };
}
