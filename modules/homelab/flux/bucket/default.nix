{
  config,
  lib,
  ...
}: let
  cfg = config.homelab.flux;
in {
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
            bucketName = cfg.bucketName;
            endpoint = cfg.endpoint;
            provider = "aws";
            secretRef.name = "flux-s3-credentials";
          };
        }
      ];
    };
  };
}
