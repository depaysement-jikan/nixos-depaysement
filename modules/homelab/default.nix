{
  config,
  system,
  ...
}: {
  imports = [
    ./k3s
    ./flux
    ./security
    ./services
    ./rclone
    ./ingress-nginx
    ./vaultwarden
    ./cert-manager
    ./garage
    ./databases
  ];

  nixpkgs = {
    overlays = import ../utils config;
    hostPlatform = system;
  };

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
    vaultwarden = {
      enable = true;
      replicas = 1;
      ingressHost = null;
      db = {
        resources = {
          requests = {
            memory = "130Mi";
          };
          limits.memory = "200Mi";
        };
      };
      resources = {
        requests = {
          memory = "50Mi";
        };
        limits.memory = "100Mi";
      };
    };
    databases = {
      cloudnative-pg = {
        enable = true;
      };
    };

    # TODO: Future configs

    cert-manager = {
      enable = false;
    };
    garage = {
      ingressHost = null;
    };
  };
}
