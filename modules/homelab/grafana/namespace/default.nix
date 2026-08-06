{
  lib,
  config,
  ...
}: {
  config = lib.mkIf (config.homelab.grafana.enable && config.homelab.enable) {
    services.k3s.manifests."grafana-namespace".content = [
      {
        apiVersion = "v1";
        kind = "Namespace";
        metadata = {
          name = "grafana-system";
          labels = {
            "app.kubernetes.io/name" = "grafana";
          };
        };
      }
    ];
  };
}
