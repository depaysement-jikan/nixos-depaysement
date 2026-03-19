{
  config,
  lib,
  ...
}: {
  imports = [./namespace ./certificate];
  options.homelab.prometheus-stack = {
    enable = lib.mkEnableOption "prometheus-stack";
    prometheus = {
      enable = lib.mkEnableOption "prometheus-stack";
      ingressHost = lib.mkOption {
        type = lib.types.str;
        default = "prometheus.home";
      };
    };
    grafana = {
      enable = lib.mkEnableOption "grafana";
      ingressHost = lib.mkOption {
        type = lib.types.str;
        default = "grafana.home";
      };
      loadBalancerIP = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  config.services.k3s = lib.mkIf config.homelab.prometheus-stack.enable {
    autoDeployCharts.prometheus-stack = {
      name = "kube-prometheus-stack";
      repo = "oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack";
      version = "82.11.0";
      hash = "sha256-+lIQ47tzJY3dRUlDrc5mx2mV9HK9wZ+iHDGnP7Cxb6A=";
      targetNamespace = "monitoring";
      values = {
        grafana = {
          enabled = true;
          ingress = {
            enabled = true;
            ingressClassName = "nginx";
            hosts = ["grafana.home"];
            tls = [
              {
                secretName = "grafana-tls";
                hosts = ["grafana.home"];
              }
            ];
          };
        };

        prometheus = {
          ingress = {
            enabled = true;
            ingressClassName = "nginx";
            hosts = [config.homelab.prometheus.ingressHost];
            tls = [
              {
                secretName = "prometheus-tls";
                hosts = [config.homelab.prometheus.ingressHost];
              }
            ];
          };
        };
      };
    };
  };
}
