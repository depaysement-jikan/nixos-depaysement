{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.homelab.forgejo.enable {
    services.k3s = {
      manifests."forgejo-cert".content = [
        # --- Self-signed ClusterIssuer
        {
          apiVersion = "cert-manager.io/v1";
          kind = "ClusterIssuer";
          metadata = {
            name = "forgejo-selfsigned";
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
            name = "forgejo-cert";
            namespace = "forgejo-system";
          };
          spec = {
            secretName = "forgejo-tls";
            issuerRef = {
              name = "forgejo-selfsigned";
              kind = "ClusterIssuer";
            };
            dnsNames = ["forgejo.home"];
          };
        }
      ];
    };
  };
}
