{
  lib,
  config,
  ...
}: {
  config = lib.mkIf (config.homelab.prometheus.enable && config.homelab.enable) {
    services.k3s = {
      manifests."prometheus-cert".content = [
        # --- Self-signed ClusterIssuer
        {
          apiVersion = "cert-manager.io/v1";
          kind = "ClusterIssuer";
          metadata = {
            name = "prometheus-selfsigned";
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
            name = "prometheus-cert";
            namespace = "prometheus-system";
          };
          spec = {
            secretName = "prometheus-tls";
            issuerRef = {
              name = "prometheus-selfsigned";
              kind = "ClusterIssuer";
            };
            dnsNames = ["prometheus.home"];
          };
        }
      ];
    };
  };
}
