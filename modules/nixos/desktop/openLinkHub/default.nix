{
  config,
  lib,
  ...
}: {
  options.nixos-generic.desktop.openLinkHub.enable = lib.mkEnableOption "openLinkHub settings";
  config = lib.mkIf config.nixos-generic.desktop.openLinkHub.enable {
    systemd.services.openlinkhub = {
      description = "OpenLinkHub";
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        WorkingDirectory = "/home/kokoro/code/OpenLinkHub";
        ExecStart = "/home/kokoro/.nix-profile/bin/OpenLinkHub";

        User = "root";
        Group = "root";

        Restart = "on-failure";
        RestartSec = 5;
      };
    };
    services.nginx = {
      enable = true;

      virtualHosts."rgb.localhost" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:27003";
        };
      };
    };
  };
}
