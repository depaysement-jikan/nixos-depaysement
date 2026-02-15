{config, ...}: let
  cfg = config.homelab.flux;
in {
  services.k3s = {
    manifests."flux-bucket" = {
      content = [
        {
          apiVersion = "source.toolkit.fluxcd.io/v1";
          kind = "Bucket";
          metadata = {
            name = "s3-bucket";
            namespace = "flux-system";
          };
          spec = {
            interval = "1m";
            bucketName = "test";
            endpoint = "test";
            provider = "aws";
            secretRef.name = "flux-s3-credentials";
          };
        }
      ];
    };
    secrets = [
      {
        metadata = {
          name = "flux-bucket";
          namespace = "default";
        };
        spec = {
          interval = "1m";
          bucketName = cfg.bucketName;
          endpoint = cfg.endpoint;
          provider = "aws";
          secretRef.name = "flux-s3-credentials";
        };
      }
    ];
  };
}
