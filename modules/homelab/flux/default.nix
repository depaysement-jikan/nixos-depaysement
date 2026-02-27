# kubectl apply -f https://github.com/fluxcd/flux2/releases/latest/download/install.yaml
# sudo kubectl apply -f /var/lib/rancher/k3s/server/manifests/flux-discord-webhook.json
# sudo kubectl apply -f /var/lib/rancher/k3s/server/manifests/flux-s3-credentials.json
# sudo kubectl apply -f /var/lib/rancher/k3s/server/manifests/flux-bucket.json
{
  lib,
  pkgs,
  ...
}: {
  imports = [./namespace ./bucket ./discord ./kustomization];
  options.homelab.flux = {
    endpoint = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    webhook = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    accessKeyId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    secretAccessKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    bucketName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    manifests = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
    };
  };
  config = {
    environment = {
      systemPackages = [pkgs.fluxcd];
      variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    };
  };
}
