{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {yaak.enable = lib.mkEnableOption "Enable yaak module";};
  config = lib.mkIf config.myHomeConfig.apps.development.api-clients.yaak.enable {
    home.packages = with pkgs; [yaak];
  };
}
