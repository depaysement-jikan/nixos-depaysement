{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.homelab.prometheus.enable {
    services.k3s.manifests."prometheus-namespace".content = [
      {
        apiVersion = "v1";
        kind = "Namespace";
        metadata = {
          name = "prometheus-system";
          labels = {
            "app.kubernetes.io/name" = "prometheus";
          };
        };
      }
    ];
  };
}
