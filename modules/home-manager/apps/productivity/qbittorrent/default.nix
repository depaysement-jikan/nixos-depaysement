{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {qbittorrent.enable = lib.mkEnableOption "Enable qbittorrent module";};
  config = lib.mkIf config.homeManager.apps.productivity.qbittorrent.enable {
    home.packages = with pkgs; [
      qbittorrent
      qbittorrent-cli
    ];
  };
}
