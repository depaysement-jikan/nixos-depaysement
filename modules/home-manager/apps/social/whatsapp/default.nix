{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {whatsapp.enable = lib.mkEnableOption "Enable whatsapp module";};
  config = lib.mkIf config.myHomeConfig.apps.social.whatsapp.enable {
    home.packages = with pkgs; [whatsapp-electron];
  };
}
