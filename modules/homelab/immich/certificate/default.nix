{
  lib,
  config,
  ...
}: {
  config = lib.mkIf (config.homelab.immich.enable && config.homelab.enable) {
    services.k3s = {
      manifests."immich-cert".content = [
        # --- Self-signed ClusterIssuer
        {
          apiVersion = "cert-manager.io/v1";
          kind = "ClusterIssuer";
          metadata = {
            name = "immich-selfsigned";
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
            name = "immich-cert";
            namespace = "immich";
          };
          spec = {
            secretName = "immich-tls";
            issuerRef = {
              name = "immich-selfsigned";
              kind = "ClusterIssuer";
            };
            dnsNames = ["immich.home"];
          };
        }
      ];
    };
  };
}
