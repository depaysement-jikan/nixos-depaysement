{...}: {
  services.k3s.manifests."uptime-kuma-namespace".content = [
    {
      apiVersion = "v1";
      kind = "Namespace";
      metadata = {
        name = "kuma-system";
        labels = {
          "app.kubernetes.io/name" = "uptime-kuma";
        };
      };
    }
  ];
}
