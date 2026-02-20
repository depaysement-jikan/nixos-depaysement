{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {postgres.enable = lib.mkEnableOption "Enable postgres module";};
  config = lib.mkIf config.myHomeConfig.apps.development.db.postgres.enable {
    home.packages = with pkgs; [postgresql];
  };
}
