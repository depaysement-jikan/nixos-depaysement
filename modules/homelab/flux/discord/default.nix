{config, ...}: let
  cfg = config.homelab.flux;
in {
  services.k3s = {
    manifests."flux-discord-provider" = {
      enable = cfg.webhook != null;
      content = [
        {
          apiVersion = "notification.toolkit.fluxcd.io/v1beta3";
          kind = "Provider";
          metadata = {
            name = "discord";
            namespace = "flux-system";
          };
          spec = {
            type = "discord";
            secretRef.name = "flux-discord-webhook";
          };
        }
        {
          apiVersion = "notification.toolkit.fluxcd.io/v1beta3";
          kind = "Alert";
          metadata = {
            name = "discord-alert";
            namespace = "flux-system";
          };
          spec = {
            providerRef = {
              name = "discord";
            };
            eventSeverity = "info";
            eventSources = [
              {
                kind = "Kustomization";
                name = "*";
                namespace = "flux-system";
              }
              {
                kind = "Bucket";
                name = "*";
                namespace = "flux-system";
              }
              {
                kind = "GitRepository";
                name = "*";
                namespace = "flux-system";
              }
            ];
          };
        }
      ];
    };
    secrets = [
      {
        apiVersion = "v1";
        kind = "Secret";
        metadata = {
          name = "flux-discord-webhook";
          namespace = "flux-system";
        };
        stringData.address = cfg.webhook;
      }
    ];
  };
}
