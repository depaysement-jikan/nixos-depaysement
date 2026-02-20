{...}: {
  services.k3s.manifests."vaultwarden-namespace".content = [
    {
      apiVersion = "v1";
      kind = "Namespace";
      metadata = {
        name = "vaultwarden";
        labels = {
          "app.kubernetes.io/name" = "vaultwarden";
        };
      };
    }
  ];
}
