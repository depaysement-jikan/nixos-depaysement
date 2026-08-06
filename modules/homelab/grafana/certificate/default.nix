{
  lib,
  config,
  ...
}: {
  config = lib.mkIf (config.homelab.grafana.enable && config.homelab.enable) {
    services.k3s = {
      manifests."grafana-cert".content = [
        # --- Self-signed ClusterIssuer
        {
          apiVersion = "cert-manager.io/v1";
          kind = "ClusterIssuer";
          metadata = {
            name = "grafana-selfsigned";
          };
          spec = {
            selfSigned = {};
          };
        }

        # --- Certificate using self-signed issuer
        {
          apiVersion = "cert-manager.io/v1";
          kind = "Certificate";
          metadata = {
            name = "grafana-cert";
            namespace = "grafana-system";
          };
          spec = {
            secretName = "grafana-tls";
            issuerRef = {
              name = "grafana-selfsigned";
              kind = "ClusterIssuer";
            };
            dnsNames = ["grafana.home"];
          };
        }
      ];
    };
  };
}
