{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {sioyek.enable = lib.mkEnableOption "Enable sioyek module";};
  config = lib.mkIf config.homeManager.apps.productivity.sioyek.enable {
    home.packages = with pkgs; [
      sioyek
    ];
  };
}
