# TODO: longhorn https
{
  lib,
  config,
  ...
}: {
  imports = [./namespace ./openiscsi];
  options.homelab.longhorn = {
    enable = lib.mkEnableOption "longhorn";
    replicas = lib.mkOption {
      type = lib.types.int;
      default = 1;
    };
    ingressHost = lib.mkOption {
      type = lib.types.str;
      default = "longhorn.home";
    };
    loadBalancerIP = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.206";
      description = "Address for the Longhorn UI Service.";
    };
  };

  config.homelab.metallb.claims = lib.mkIf (config.homelab.longhorn.enable && config.homelab.enable) [
    {
      owner = "longhorn (ui)";
      ip = config.homelab.longhorn.loadBalancerIP;
    }
  ];

  config.services.k3s = lib.mkIf (config.homelab.longhorn.enable && config.homelab.enable) {
    autoDeployCharts.longhorn = {
      name = "longhorn";
      repo = "https://charts.longhorn.io";
      version = "1.11.0";
      hash = "sha256-fpBaiw3DJ0KRQ1Co5AYjT/WuZR1LjD+Zq6hKg2CKG/Y=";
      targetNamespace = "longhorn-system";
      values = {
        image.longhorn.instanceManager.tag = "v1.11.0-hotfix-1";
        replicas = config.homelab.longhorn.replicas;
        service = {
          ui = {
            type = "LoadBalancer";
            loadBalancerIP = config.homelab.longhorn.loadBalancerIP;
          };
        };
        ingress = {
          enabled = true;
          ingressClassName = "nginx";
          host = config.homelab.longhorn.ingressHost;
          tls = false;
        };
      };
    };
  };
}
