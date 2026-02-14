{
  lib,
  config,
  ...
}: {
  imports = [./zen ./firefox ./floorp];

  options = {browsers.enable = lib.mkEnableOption "Enable browsers module";};
  config = lib.mkIf config.browsers.enable {
    zen.enable = lib.mkDefault true;
    firefox.enable = lib.mkDefault true;
    floorp.enable = lib.mkDefault true;
  };
}
