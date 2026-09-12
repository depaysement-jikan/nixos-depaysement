{
  lib,
  config,
  ...
}: let
  mkAnubis =
    import ./mk-anubis.nix;
in {
  imports = [./namespace];
  options.homelab.anubis = {
    enable = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = true;
    };
    instances = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          target = lib.mkOption {
            type = lib.types.str;
          };

          ingressHost = lib.mkOption {
            type = lib.types.str;
          };

          tlsSecretName = lib.mkOption {
            type = lib.types.str;
          };

          replicas = lib.mkOption {
            type = lib.types.int;
            default = 1;
          };

          difficulty = lib.mkOption {
            type = lib.types.str;
            default = "4";
          };
        };
      });

      default = {};
    };
  };
  config = lib.mkIf (config.homelab.anubis.enable && config.homelab.enable) {
    services.k3s.manifests."anubis".content = lib.flatten (lib.mapAttrsToList mkAnubis config.homelab.anubis.instances);
  };
}
