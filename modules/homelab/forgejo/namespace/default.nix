{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.homelab.forgejo.enable {
    services.k3s.manifests."forgejo-namespace".content = [
      {
        apiVersion = "v1";
        kind = "Namespace";
        metadata = {
          name = "forgejo-system";
          labels = {
            "app.kubernetes.io/name" = "forgejo";
          };
        };
      }
    ];
  };
}
