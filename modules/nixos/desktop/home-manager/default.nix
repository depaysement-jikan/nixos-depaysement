{
  config,
  pkgs,
  lib,
  ...
}: {
  options.nixos-generic.desktop.homeManager = {
    enable = lib.mkEnableOption "Home Manager";
  };

  config = lib.mkIf config.nixos-generic.desktop.homeManager.enable {
    environment.systemPackages = [
      pkgs.home-manager
    ];
  };
}
