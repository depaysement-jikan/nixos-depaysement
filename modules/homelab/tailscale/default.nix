{
  lib,
  config,
  pkgs,
  ...
}: {
  options.homelab.tailscale = {
    enable = lib.mkEnableOption "tailscale funnel";
    port = lib.mkOption {
      type = lib.types.ints.between 1 65535;
      default = 80;
      description = "Port to expose via Tailscale funnel";
    };
    authKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to Tailscale auth key file";
    };
  };

  config = lib.mkIf config.homelab.tailscale.enable {
    environment = {
      systemPackages = [pkgs.tailscale];
    };

    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "both";

      authKeyFile = config.homelab.tailscale.authKeyFile;
      authKeyParameters = {
        ephemeral = null;
        baseURL = null;
        preauthorized = null;
      };

      extraUpFlags = [
        "--ssh"
        "--advertise-exit-node"
      ];

      extraSetFlags = [
        "--advertise-routes=192.168.1.0/24"
      ];

      extraDaemonFlags = [
        "--no-logs-no-support"
      ];
    };
  };
}
