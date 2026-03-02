# TODO: immich https
{
  lib,
  config,
  ...
}: {
  imports = [./namespace ./db ./pvc];
  options.homelab.immich = {
    enable = lib.mkEnableOption "immich";
    replicas = lib.mkOption {
      type = lib.types.int;
      default = 1;
    };
    ingresshost = lib.mkOption {
      type = lib.types.str;
      default = "immich.home";
    };
    storageClass = lib.mkOption {
      type = lib.types.str;
      default = "local-path";
    };
    db = {
      instances = lib.mkOption {
        type = lib.types.int;
        default = 1;
        description = "Number of cnpg instances for immich";
      };
      size = lib.mkOption {
        type = lib.types.str;
        default = "1Gi";
      };
    };
  };
  config.services.k3s = lib.mkIf config.homelab.immich.enable {
    autoDeployCharts.immich = {
      name = "immich";
      repo = "https://immich-app.github.io/immich-charts";
      version = "0.10.3";
      hash = "sha256-E9lqIjUe1WVEV8IDrMAbBTJMKj8AzpigJ7fNDCYYo8Y=";
      targetNamespace = "immich";
      values = {
        valkey.enabled = true;
        replicas = config.homelab.immich.replicas;
        service = {
          type = "LoadBalancer";
          loadBalancerIP = "192.168.1.206";
        };
        ingress = {
          enabled = true;
          ingressClassName = "nginx";
          host = config.homelab.immich.ingresshost;
          tls = false;
        };
        immich.persistence.library.existingClaim = "immich-library-pvc";
      };
    };
  };
}
