{
  lib,
  config,
  ...
}: {
  imports = [./yaak];
  options = {
    api-clients.enable = lib.mkEnableOption "Enable api-clients module";
  };
  config = lib.mkIf config.myHomeConfig.apps.development.api-clients.enable {
    yaak.enable = lib.mkDefault true;
  };
}
