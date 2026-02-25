{
  lib,
  config,
  ...
}: let
  inherit (lib) types;
in {
  imports = [./namespace ./cluster-issuer ./crds];

  options.homelab.cert-manager = {
    enable = lib.mkOption {
      type = types.bool;
      default = true;
    };

    injector.resources = lib.mkOption {
      type = types.attrsOf (types.attrsOf (types.nullOr types.str));
      description = "Kubernetes resource requests/limits.";
    };
    controller.resources = lib.mkOption {
      type = types.attrsOf (types.attrsOf (types.nullOr types.str));
      description = "Kubernetes resource requests/limits.";
    };
    webhook.resources = lib.mkOption {
      type = types.attrsOf (types.attrsOf (types.nullOr types.str));
      description = "Kubernetes resource requests/limits.";
    };
  };

  config.services.k3s = lib.mkIf config.homelab.cert-manager.enable {
    autoDeployCharts.cert-manager = {
      name = "cert-manager";
      repo = "https://charts.jetstack.io";
      version = "1.19.3";
      hash = "sha256-orpAnHvluMXpjQUhJdjEmcAwxOYPOl7j+Qs43ggW61E=";
      targetNamespace = "cert-manager";
    };
  };
}
