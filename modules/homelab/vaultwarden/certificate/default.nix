{...}: {
  services.k3s = {
    manifests."vaultwarden-cert".content = [
      # --- Self-signed ClusterIssuer
      {
        apiVersion = "cert-manager.io/v1";
        kind = "ClusterIssuer";
        metadata = {
          name = "vaultwarden-selfsigned";
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
          name = "vaultwarden-cert";
          namespace = "vaultwarden";
        };
        spec = {
          secretName = "vaultwarden-tls";
          issuerRef = {
            name = "vaultwarden-selfsigned";
            kind = "ClusterIssuer";
          };
          dnsNames = ["vault.home"];
        };
      }
    ];
  };
}
