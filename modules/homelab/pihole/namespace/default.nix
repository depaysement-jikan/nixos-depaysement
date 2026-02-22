{...}: {
  services.k3s.manifests."pihole-namespace".content = [
    {
      apiVersion = "v1";
      kind = "Namespace";
      metadata = {
        name = "pihole-system";
        labels = {
          "app.kubernetes.io/name" = "piihole";
        };
      };
    }
  ];
}
