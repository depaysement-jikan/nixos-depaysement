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
        server = {
          ingress = {
            main = {
              enabled = true;
              className = "nginx";
              annotations = {
                "nginx.ingress.kubernetes.io/proxy-body-size" = "0";
              };
              hosts = [
                {
                  host = "immich.home";
                  paths = [
                    {
                      path = "/";
                      service = {
                        identifier = "main";
                      };
                    }
                  ];
                }
              ];
              tls = false;
            };
          };

          controllers = {
            main = {
              containers = {
                main = {
                  env = {
                    DB_HOSTNAME = {
                      valueFrom = {
                        secretKeyRef = {
                          name = "immich-database-app";
                          key = "host";
                        };
                      };
                    };
                    DB_USERNAME = {
                      valueFrom = {
                        secretKeyRef = {
                          name = "immich-database-app";
                          key = "user";
                        };
                      };
                    };
                    DB_PASSWORD = {
                      valueFrom = {
                        secretKeyRef = {
                          name = "immich-database-app";
                          key = "password";
                        };
                      };
                    };
                    DB_DATABASE_NAME = {
                      valueFrom = {
                        secretKeyRef = {
                          name = "immich-database-app";
                          key = "dbname";
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
        replicas = config.homelab.immich.replicas;
        service = {
          type = "ClusterIP";
        };
        immich.persistence.library.existingClaim = "immich-library-pvc";
      };
    };
  };
}
