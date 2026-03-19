{
  config,
  system,
  ...
}: {
  imports = [
    ./k3s
    ./flux
    ./security
    ./services
    ./rclone
    ./ingress-nginx
    ./vaultwarden
    ./cert-manager
    ./garage
    ./databases
    ./metallb
    ./pihole
    ./tailscale
    ./longhorn
    ./immich
    ./prometheus
    ./prometheus-stack
    ./grafana
    ./uptime-kuma
  ];

  nixpkgs = {
    overlays = import ../utils config;
    hostPlatform = system;
  };
}
