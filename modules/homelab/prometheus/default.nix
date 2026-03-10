{lib, ...}: {
  imports = [];
  options.homelab = {
    prometheus = {
      enable = lib.mkEnableOption "prometheus";
      ingressHost = lib.mkOption {
        type = lib.types.str;
        default = "prometheus.home";
      };
    };
  };
}
