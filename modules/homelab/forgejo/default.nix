{
  config,
  lib,
  ...
}: {
  imports = [./namespace ./certificate];
  options.homelab = {
    forgejo = {
      enable = lib.mkEnableOption "forgejo";
      httpLoadBalancerIP = lib.mkOption {
        type = lib.types.str;
      };
      sshLoadBalancerIP = lib.mkOption {
        type = lib.types.str;
      };
      ingressHost = lib.mkOption {
        type = lib.types.str;
        default = "forgejo.home";
      };
    };
  };

  config.services.k3s = lib.mkIf (config.homelab.forgejo.enable && config.homelab.enable) {
    autoDeployCharts.forgejo = {
      name = "forgejo";
      repo = "oci://code.forgejo.org/forgejo-helm/forgejo";
      version = "16.2.1";
      hash = "sha256-Ct6YvKVbNpESeH8AwEhvlXDiSiuXlYnnRBJupf0YIjs=";
      targetNamespace = "forgejo-system";
      values = {
        gitea = {
          metrics.enable = true;
          serviceMonitor = {
            enabled = false;
            namespace = "monitoring";
          };
        };
        service = {
          http = {
            type = "LoadBalancer";
            loadBalancerIP = config.homelab.forgejo.httpLoadBalancerIP;
          };
          ssh = {
            type = "LoadBalancer";
            loadBalancerIP = config.homelab.forgejo.sshLoadBalancerIP;
          };
        };
        ingress = {
          enabled = true;
          className = "nginx";

          hosts = [
            {
              host = config.homelab.forgejo.ingressHost;
              paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  port = "http";
                }
              ];
            }
          ];

          tls = [
            {
              secretName = "forgejo-tls";
              hosts = [config.homelab.forgejo.ingressHost];
            }
          ];
        };
      };
    };
  };
}
