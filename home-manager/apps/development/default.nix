{ lib, config, ... }: {
  imports = [ ./terminal ./api-clients ];

  options = {
    development.enable = lib.mkEnableOption "Enable development module";
  };
  config = lib.mkIf config.development.enable {
    terminal.enable = lib.mkDefault true;
    api-clients.enable = lib.mkDefault true;
  };
}
