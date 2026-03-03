{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.homelab.immich.enable {
    services.k3s.manifests."immich-library-pvc".content = [
      {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "immich-library-pvc";
          namespace = "immich";
          labels = {
            "app.kubernetes.io/name" = "immich-pvc";
          };
        };
        spec = {
          storageClassName = config.homelab.immich.storageClass;
          accessModes = ["ReadWriteOnce"];
          resources = {
            requests = {
              storage = "30Gi";
            };
          };
        };
      }
    ];
  };
}
