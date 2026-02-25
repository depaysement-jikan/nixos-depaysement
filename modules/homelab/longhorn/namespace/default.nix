{...}: {
  services.k3s.manifests."longhorn-namespace".content = [
    {
      apiVersion = "v1";
      kind = "Namespace";
      metadata = {
        name = "longhorn-system";
        labels = {
          "app.kubernetes.io/name" = "longhorn";
        };
      };
    }
  ];
}
