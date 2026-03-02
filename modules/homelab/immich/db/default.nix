{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.homelab.immich.enable {
    services.k3s = {
      manifests.immich-databases.content = {
        apiVersion = "postgresql.cnpg.io/v1";
        kind = "Cluster";
        metadata = {
          name = "immich-database";
          namespace = "immich";
        };
        spec = {
          instances = config.homelab.immich.db.instances;
          storage = {
            size = config.homelab.immich.db.size;
          };
          imageName = "ghcr.io/tensorchord/cloudnative-vectorchord:16.9-0.4.3";
          postgresql.shared_preload_libraries = ["vchord.so"];
          pbootstrap.initdb.postInitApplicationSQL = [
            "CREATE EXTENSION vchord CASCADE"
            "CREATE EXTENSION earthdistance CASCADE"
          ];
        };
      };
    };
  };
}
