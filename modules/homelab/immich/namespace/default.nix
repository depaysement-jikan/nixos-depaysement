{...}: {
  services.k3s.manifests."immich-namespace".content = [
    {
      apiVersion = "v1";
      kind = "Namespace";
      metadata = {
        name = "immich";
        labels = {
          "app.kubernetes.io/name" = "immich";
        };
      };
    }
  ];
}
