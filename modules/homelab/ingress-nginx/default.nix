{
  lib,
  config,
  ...
}: {
  imports = [
    ./namespace.nix
  ];

  options.homelab.ingress = {
    enable = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = true;
    };
    resources = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf (lib.types.nullOr lib.types.str));
      description = "Kubernetes resource requests/limits for ingress-nginx.";
    };
  };

  config = lib.mkIf config.homelab.ingress.enable {
    services.k3s.autoDeployCharts.ingress-nginx = {
      name = "ingress-nginx";
      repo = "https://kubernetes.github.io/ingress-nginx";
      hash = "sha256-nJdgCyNMcM7/ua3OXGam6X5p4nBkmbsDCCFdtKMQdp8=";
      version = "4.14.3";
      targetNamespace = "ingress-nginx";

      values = {
        controller = {
          hostNetwork = true;
          service = {
            enabled = false;
          };
        };
        defaultBackend = {enabled = false;};
      };
    };
  };
}
