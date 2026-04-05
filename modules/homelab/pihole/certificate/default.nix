{
  lib,
  config,
  ...
}: {
  config = lib.mkIf (config.homelab.pihole.enable && config.homelab.enable) {
    services.k3s = {
      manifests."pihole-cert".content = [
        # --- Self-signed ClusterIssuer
        {
          apiVersion = "cert-manager.io/v1";
          kind = "ClusterIssuer";
          metadata = {
            name = "pihole-selfsigned";
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
            name = "pihole-cert";
            namespace = "pihole-system";
          };
          spec = {
            secretName = "pihole-tls";
            issuerRef = {
              name = "pihole-selfsigned";
              kind = "ClusterIssuer";
            };
            dnsNames = ["pi.home"];
          };
        }
      ];
    };
  };
}
