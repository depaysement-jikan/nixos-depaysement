{
  config,
  lib,
  ...
}: {
  imports = [./namespace ./certificate];
  options.homelab = {
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

  # If password is not programatically set it can be found at
  # k get secret -n grafana-system grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo
  config.services.k3s = lib.mkIf (config.homelab.grafana.enable && config.homelab.enable) {
    autoDeployCharts.grafana = {
      name = "grafana";
      repo = "https://grafana-community.github.io/helm-charts/";
      version = "11.3.2";
      hash = "sha256-zlQkYsiM2ZCY/VFUp3mXCC261L+E2N7sxfHnSZfNS6M=";
      targetNamespace = "grafana-system";
      values = {
        service = {
          type = "LoadBalancer";
          loadBalancerIP = config.homelab.grafana.loadBalancerIP;
        };
        ingress = {
          enabled = true;
          ingressClassName = "nginx";
          hosts = [config.homelab.grafana.ingressHost];
          tls = [
            {
              secretName = "grafana-tls";
              hosts = [config.homelab.grafana.ingressHost];
            }
          ];
        };
      };
    };
  };
}
