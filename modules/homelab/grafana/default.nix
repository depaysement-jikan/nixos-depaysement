{lib, ...}: {
  imports = [];
  options.homelab = {
    grafana = {
      enable = lib.mkEnableOption "grafana";
      ingresshost = lib.mkOption {
        type = lib.types.str;
        default = "prometheus.home";
      };
    };
  };
}
