{config, ...}: {
  imports = [
    ./flux
    ./security
    ./services
    ./rclone
  ];

  homelab = {
    flux = {
      bucketName = "sodachi";
      endpoint = config.sops.placeholder.fluxEndpoint;
      accessKeyId = config.sops.placeholder.fluxAccessKeyId;
      secretAccessKey = config.sops.placeholder.fluxSecretKey;
      webhook = config.sops.placeholder.fluxDiscordWebhookUrl;
    };
  };
  services.k3s = {
    enable = true;
    extraFlags = [
      "--write-kubeconfig-group k3s"
      "--write-kubeconfig-mode 0660"
    ];
  };

  users.groups.k3s = {};
}
