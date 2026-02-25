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
    ingresshost = lib.mkOption {
      type = lib.types.str;
      default = "longhorn.home";
    };
  };
  config.services.k3s = lib.mkIf config.homelab.longhorn.enable {
    autoDeployCharts.longhorn = {
      name = "longhorn";
      repo = "https://charts.longhorn.io";
      version = "1.11.0";
      hash = "sha256-fpBaiw3DJ0KRQ1Co5AYjT/WuZR1LjD+Zq6hKg2CKG/Y=";
      targetNamespace = "longhorn-system";
      values = {
        replicas = config.homelab.longhorn.replicas;
        service = {
          ui = {
            type = "LoadBalancer";
            loadBalancerIP = "192.168.1.205";
          };
        };
        ingress = {
          enabled = true;
          ingressClassName = "nginx";
          host = config.homelab.longhorn.ingresshost;
          tls = false;
        };
      };
    };
  };
}
