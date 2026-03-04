{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.homelab.flux.enable {
    services.k3s = {
      secrets = [
        {
          apiVersion = "source.toolkit.fluxcd.io/v1";
          kind = "Bucket";
          metadata = {
            name = "flux-bucket";
            namespace = "flux-system";
          };
          spec = {
            interval = "1m";
            bucketName = config.homelab.flux.bucketName;
            endpoint = config.homelab.flux.endpoint;
            provider = "aws";
            secretRef.name = "flux-s3-credentials";
          };
        }
      ];
    };
  };
}
