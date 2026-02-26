{lib, ...}: {
  imports = [];
  options.homelab = {
    prometheus = {
      enable = lib.mkEnableOption "prometheus";
      ingresshost = lib.mkOption {
        type = lib.types.str;
        default = "prometheus.home";
      };
    };
  };
}
