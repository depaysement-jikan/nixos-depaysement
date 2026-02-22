{
  lib,
  config,
  ...
}: {
  imports = [./namespace ./db];

  options.homelab.vaultwarden = {
    enable = lib.mkEnableOption "vaultwarden";
    replicas = lib.mkOption {
      type = lib.types.int;
      default = 1;
    };

    gated = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to gate this service behind oauth2-proxy";
    };

    ingressHost = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Host in which the vault will be served";
    };

    resources = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf (lib.types.nullOr lib.types.str));
      description = "Kubernetes resource requests/limits for vaultwarden container.";
    };
  };
  config.services.k3s = lib.mkIf config.homelab.vaultwarden.enable {
    # If stuck because namespace deletion:
    #   kubectl delete job -n kube-system helm-install-vaultwarden
    #   kubectl delete pod -n kube-system helm-install-vaultwarden-bj2n6
    autoDeployCharts.vaultwarden = {
      name = "vaultwarden";
      repo = "https://guerzon.github.io/vaultwarden";
      version = "0.34.4";
      hash = "sha256-qn2kfuXoLqHLyacYrBwvKgVb+qZjMu+E16dq9jJS3RE=";
      targetNamespace = "vaultwarden";

      values = {
        replicas = config.homelab.vaultwarden.replicas;

        serviceAccount = {
          create = true;
          name = "vaultwarden-svc";
        };

        # TODO: Remove later when a better way to reach vault is found
        service = {
          type = "LoadBalancer";
          loadBalancerIP = "192.168.1.201";
        };

        webVaultEnabled = true;

        database = {
          type = "postgresql";
          existingSecret = "vaultwarden-db-app";
          existingSecretKey = "uri";
          connectionRetries = 30;
        };

        domain =
          if config.homelab.vaultwarden.ingressHost != null
          then "https://${config.homelab.vaultwarden.ingressHost}"
          else "https://localhost";

        ingress =
          # Access through pf
          # kubectl port-forward svc/vaultwarden 8080:80 -n vaultwarden
          if config.homelab.vaultwarden.ingressHost != null
          then {
            enabled = true;
            class = "nginx";
            nginxIngressAnnotations = true;
            additionalAnnotations =
              {
                "nginx.ingress.kubernetes.io/rewrite-target" = "/";
              }
              // lib.optionalAttrs config.homelab.cert-manager.enable {
                "cert-manager.io/cluster-issuer" = "letsencrypt";
              }
              // lib.optionalAttrs config.homelab.vaultwarden.gated {
                "nginx.ingress.kubernetes.io/auth-signin" = "https://${config.homelab.auth.oauth2-proxy.ingressHost}/oauth2/start?rd=https://$host$escaped_request_uri";
                "nginx.ingress.kubernetes.io/auth-url" = "http://oauth2-proxy.auth.svc.cluster.local/oauth2/auth";
                "nginx.ingress.kubernetes.io/auth-response-headers" = "X-Auth-Request-User,X-Auth-Request-Email";
              };
            labels = {};
            tls = true;
            hostname = config.homelab.vaultwarden.ingressHost;
            path = "/";
            pathType = "Prefix";
            tlsSecret = "vaultwarden-tls";
          }
          else {};

        resources = config.homelab.vaultwarden.resources;
      };
    };
  };
}
