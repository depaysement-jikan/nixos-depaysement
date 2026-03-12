{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.homelab.uptime-kuma.enable {
    services.k3s = {
      manifests."uptime-kuma-cert".content = [
        # --- Self-signed ClusterIssuer
        {
          apiVersion = "cert-manager.io/v1";
          kind = "ClusterIssuer";
          metadata = {
            name = "uptime-kuma-selfsigned";
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
            name = "uptime-kuma-cert";
            namespace = "kuma-system";
          };
          spec = {
            secretName = "uptime-kuma-tls";
            issuerRef = {
              name = "uptime-kuma-selfsigned";
              kind = "ClusterIssuer";
            };
            dnsNames = ["kuma.home"];
          };
        }
      ];
    };
  };
}
