{
  lib,
  config,
  ...
}: {
  imports = [./discord ./whatsapp ./spotify];
  options = {social.enable = lib.mkEnableOption "Enable web module";};
  config = lib.mkIf config.social.enable {
    discord.enable = lib.mkDefault true;
    whatsapp.enable = lib.mkDefault true;
    spotify.enable = lib.mkDefault true;
  };
}
