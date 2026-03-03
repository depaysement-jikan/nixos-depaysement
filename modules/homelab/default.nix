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
    ./metallb
    ./pihole
    ./tailscale
    ./longhorn
    ./immich
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
      ingressHost = "vault.home";
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
    metallb = {
      enable = true;
      replicas = 1;
      addresses = [
        "192.168.1.201-192.168.1.254"
      ];
    };
    longhorn = {
      # TODO: This is causing issues with flannel generation, disabled for now, Flux might fix it
      # context: https://github.com/k3s-io/k3s/issues/13277#issuecomment-3837472085
      enable = false;
      replicas = 1;
      ingresshost = "longhorn.home";
    };
    immich = {
      enable = true;
      replicas = 1;
      ingresshost = "immich.home";
      storageClass = "local-path";
      db = {
        instances = 1;
        size = "1Gi";
      };
    };
    pihole = {
      enable = true;
      password = config.sops.placeholder.piholePassword;
      gated = false;
      webLoadBalancerIP = "192.168.1.204";
      dnsLoadBalancerIP = "192.168.1.204";
      dns = "192.168.1.1";
    };
    cert-manager = {
      enable = true;
      email = config.sops.placeholder.certEmail;
    };
    tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets.tailscaleAuthKey.path;
    };

    # TODO: Future configs

    garage = {
      ingressHost = null;
    };
  };
}
