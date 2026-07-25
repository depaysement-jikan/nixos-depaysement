{
  lib,
  pkgs,
  config,
  ...
}: {
  options = {openLinkHub.enable = lib.mkEnableOption "Enable openLinkHub module";};
  config = lib.mkIf config.homeManager.system.openLinkHub.enable {
    home = {
      packages = with pkgs; [openlinkhub];
    };
  };
}
