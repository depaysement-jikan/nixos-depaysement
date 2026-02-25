{lib, ...}: let
  inherit (lib) types;
in {
  imports = [
    ./namespace.nix
  ];

  options.homelab.ingress = {
    resources = lib.mkOption {
      type = types.attrsOf (types.attrsOf (types.nullOr types.str));
      description = "Kubernetes resource requests/limits for ingress-nginx.";
    };
  };

  config = {
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
