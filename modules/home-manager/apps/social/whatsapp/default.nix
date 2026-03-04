{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {whatsapp.enable = lib.mkEnableOption "Enable whatsapp module";};
  config = lib.mkIf config.homeManager.apps.social.whatsapp.enable {
    home.packages = with pkgs; [whatsapp-electron];
  };
}
