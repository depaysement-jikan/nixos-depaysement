{config, ...}: {
  imports = [
    ./k3s
    ./flux
    ./security
    ./services
    ./rclone
    ./ingress-nginx
  ];

  homelab = {
    flux = {
      bucketName = "panaino";
      endpoint = config.sops.placeholder.fluxEndpoint;
      accessKeyId = config.sops.placeholder.fluxAccessKeyId;
      secretAccessKey = config.sops.placeholder.fluxSecretKey;
      webhook = config.sops.placeholder.fluxDiscordWebhookUrl;
    };
    ingress = {
      resources = {
        requests = {
          cpu = "100m";
          memory = "200Mi";
        };
        limits.memory = "400Mi";
      };
    };
  };
}
