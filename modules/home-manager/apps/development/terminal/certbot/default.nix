{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {certbot.enable = lib.mkEnableOption "Enable certbot module";};
  config = lib.mkIf config.homeManager.apps.development.terminal.certbot.enable {
    home.packages = with pkgs; [certbot];
  };
}
