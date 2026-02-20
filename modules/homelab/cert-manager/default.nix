{lib, ...}: let
  inherit (lib) types;
in {
  imports = [];

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
}
