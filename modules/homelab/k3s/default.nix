{config, ...}: {
  config = {
    services.k3s = {
      enable = true;
      # manifestDir = "/var/lib/manifests";
      extraFlags = [
        "--disable servicelb"
        "--disable traefik"
        "--write-kubeconfig-group k3s"
        "--write-kubeconfig-mode 0660"
      ];
      secrets = [
        {
          apiVersion = "v1";
          kind = "Secret";
          metadata = {
            name = "flux-s3-credentials";
            namespace = "flux-system";
          };
          stringData = {
            accesskey = config.homelab.flux.accessKeyId;
            secretkey = config.homelab.flux.secretAccessKey;
          };
        }
      ];
    };
    users.groups.k3s = {};
  };
}
