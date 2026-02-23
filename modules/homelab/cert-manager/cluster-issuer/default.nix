{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.cert-manager;
in {
  options.homelab.cert-manager = {
    email = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Email address for Let's Encrypt certificate requests";
    };
  };

  config = lib.mkIf cfg.enable {
    services.k3s = {
      secrets = [
        {
          apiVersion = "cert-manager.io/v1";
          kind = "ClusterIssuer";
          metadata = {
            name = "cert-manager-letsencrypt-issuer";
            namespace = "cert-manager";
          };
          spec = {
            acme = {
              server = "https://acme-v02.api.letsencrypt.org/directory";
              email = config.homelab.cert-manager.email;
              privateKeySecretRef = {
                name = "letsencrypt";
              };
              solvers = [
                {
                  http01 = {
                    ingress = {
                      class = "nginx";
                    };
                  };
                }
              ];
            };
          };
        }
      ];
    };
  };
}
