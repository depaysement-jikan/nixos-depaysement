{
  lib,
  config,
  ...
}: {
  imports = [./postgres];

  options = {db.enable = lib.mkEnableOption "Enable db module";};
  config = lib.mkIf config.homeManager.apps.development.db.enable {
    db.enable = lib.mkDefault true;
  };
}
