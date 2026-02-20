{config, ...}: let
  cfg = config.homelab.flux;
in {
  # kubectl apply -f https://github.com/fluxcd/flux2/releases/latest/download/install.yaml
  # sudo kubectl apply -f /var/lib/rancher/k3s/server/manifests/flux-discord-webhook.json
  # sudo kubectl apply -f /var/lib/rancher/k3s/server/manifests/flux-s3-credentials.json
  # sudo kubectl apply -f /var/lib/rancher/k3s/server/manifests/flux-bucket.json

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
}
