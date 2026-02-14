{config, ...}: let
  cfg = config.homelab.flux;
in {
  sops.templates.flux-bucket-manifest = {
    path = "/var/lib/rancher/k3s/server/manifests/flux-bucket.yaml";
    mode = "0400";
    content = ''
      apiVersion: v1
      items:
      - apiVersion: source.toolkit.fluxcd.io/v1
        kind: Bucket
        metadata:
          name: s3-bucket
          namespace: flux-system
        spec:
          bucketName: ${cfg.bucketName}
          endpoint: ${cfg.endpoint}
          interval: 1m
          provider: aws
          secretRef:
            name: flux-s3-credentials
      kind: List

    '';
  };
}
