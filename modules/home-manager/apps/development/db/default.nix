{
  lib,
  config,
  ...
}: {
  imports = [./postgres];

  options = {db.enable = lib.mkEnableOption "Enable db module";};
  config = lib.mkIf config.myHomeConfig.apps.development.db.enable {
    db.enable = lib.mkDefault true;
  };
}
