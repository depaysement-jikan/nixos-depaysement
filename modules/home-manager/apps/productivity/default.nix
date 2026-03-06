{
  lib,
  config,
  ...
}: {
  imports = [./obsidian ./sioyek];
  options = {
    productivity.enable = lib.mkEnableOption "Enable productivity module";
  };
  config = lib.mkIf config.productivity.enable {
    obsidian.enable = lib.mkDefault true;
    sioyek.enable = lib.mkDefault true;
  };
}
