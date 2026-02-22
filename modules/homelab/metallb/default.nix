{
  lib,
  config,
  ...
}: {
  imports = [./namespace ./L2Advertisement ./ipAddressPool];
  options.homelab.metallb = {
    enable = lib.mkEnableOption "metallb";
    replicas = lib.mkOption {
      type = lib.types.int;
      default = 1;
    };
    addresses = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };
  config.services.k3s = lib.mkIf config.homelab.metallb.enable {
    autoDeployCharts.metallb = {
      name = "metallb";
      repo = "https://metallb.github.io/metallb";
      version = "0.15.3";
      hash = "sha256-J9t2HFrSUl/RMMkv4vLUUA+IcOQC/v48nLjTTYpxpww=";
      targetNamespace = "metallb-system";
      values = {
        replicas = config.homelab.metallb.replicas;
      };
    };
  };
}
