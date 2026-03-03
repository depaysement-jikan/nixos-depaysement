# Emergency reset
# sudo rm -rf /var/lib/rancher && sudo rm -rf /etc/k3s
{config, ...}: {
  config = {
    systemd.services.k3s = {
      after = ["network-online.target"];
      wants = ["network-online.target"];
    };
    services.k3s = {
      enable = false;
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
