{
  lib,
  config,
  ...
}: {
  imports = [./terminal ./api-clients ./languages ./ai ./db];

  options = {
    development.enable = lib.mkEnableOption "Enable development module";
  };
  config = lib.mkIf config.development.enable {
    terminal.enable = lib.mkDefault true;
    api-clients.enable = lib.mkDefault true;
    languages.enable = lib.mkDefault true;
    ai.enable = lib.mkDefault true;
    db.enable = lib.mkDefault true;
  };
}
