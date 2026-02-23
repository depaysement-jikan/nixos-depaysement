{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.k3s;
in {
  options.services.k3s.secrets = lib.mkOption {
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
          metadata = {
            name = lib.mkOption {type = lib.types.str;};
            namespace = lib.mkOption {type = lib.types.nullOr lib.types.str;};
          };
          spec = lib.mkOption {
            type = lib.types.nullOr (lib.types.submodule {
              options = {
                acme = lib.mkOption {
                  type = lib.types.nullOr lib.types.anything;
                  default = null;
                };
                bucketName = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                };
                endpoint = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                };
                interval = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                };
                provider = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                };
                secretRef.name = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                };
              };
            });
            default = null;
          };

          stringData = lib.mkOption {
            type = lib.types.anything;
            default = null;
          };
          apiVersion = lib.mkOption {
            type = lib.types.anything;
            default = null;
          };
          kind = lib.mkOption {
            type = lib.types.anything;
            default = null;
          };
        };
      }
    );
    default = [];
  };

  config = {
    sops.templates = lib.listToAttrs (
      map (secret: {
        name = secret.metadata.name;
        value = {
          content = builtins.toJSON (
            lib.filterAttrs (_: v: v != null) {
              apiVersion = secret.apiVersion;
              kind = secret.kind;
              metadata = secret.metadata;
              stringData = secret.stringData;
              spec = secret.spec;
            }
          );
          path = "${cfg.manifestDir}/${secret.metadata.name}.json";
        };
      })
      (lib.filter (s: s.enable) cfg.secrets)
    );

    systemd.services.k3s-secret-symlink-cleanup = {
      description = "Remove broken symlink k3s secret manifests";
      after = ["systemd-tmpfiles-resetup.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "k3s-secret-symlink-cleanup" ''
          set -euo pipefail
          dir=${lib.escapeShellArg cfg.manifestDir}

          if [ ! -d "$dir" ]; then
            exit 0
          fi

          ${pkgs.findutils}/bin/find "$dir" -maxdepth 1 -type l -name '*.json' -xtype l -print0 | \
            ${pkgs.findutils}/bin/xargs -0r ${pkgs.coreutils}/bin/rm -f
        '';
      };
    };

    systemd.timers.k3s-secret-symlink-cleanup = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "10m";
        Persistent = true;
      };
    };
  };
}
