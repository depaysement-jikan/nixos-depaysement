{
  config,
  lib,
  ...
}: {
  imports = [./namespace ./certificate];
  options.homelab = {
    prometheus = {
      enable = lib.mkEnableOption "prometheus";
      ingressHost = lib.mkOption {
        type = lib.types.str;
        default = "prometheus.home";
      };
    };
  };

  config.services.k3s = lib.mkIf (config.homelab.prometheus.enable && config.homelab.enable) {
    autoDeployCharts.prometheus = {
      name = "prometheus";
      repo = "https://prometheus-community.github.io/helm-charts";
      version = "28.13.0";
      hash = "sha256-W29NO3JnQoypwo3jqYXEeg9HxICOCwcWIdEIqtjLiNY=";
      targetNamespace = "prometheus-system";
      values = {
        alert-manager = {
          enabled = true;
        };
        server = {
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
