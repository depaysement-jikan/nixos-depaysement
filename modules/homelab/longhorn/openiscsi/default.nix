{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.homelab.longhorn.enable {
    services.openiscsi = {
      enable = true;
      name = "${config.networking.hostName}-initiatorhost";
    };
    systemd.services.iscsid.serviceConfig = {
      PrivateMounts = "yes";
      BindPaths = "/run/current-system/sw/bin:/bin";
    };
  };
}
