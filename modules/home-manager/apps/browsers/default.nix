{
  lib,
  config,
  ...
}: {
  imports = [./zen ./firefox ./floorp ./helium];

  options = {browsers.enable = lib.mkEnableOption "Enable browsers module";};
  config = lib.mkIf config.browsers.enable {
    zen.enable = lib.mkDefault true;
    firefox.enable = lib.mkDefault true;
    floorp.enable = lib.mkDefault true;
    helium.enable = lib.mkDefault true;
  };
}
