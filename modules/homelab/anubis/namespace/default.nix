{...}: {
  services.k3s.manifests."anubis-namespace".content = [
    {
      apiVersion = "v1";
      kind = "Namespace";
      metadata = {
        name = "anubis-system";
        labels = {
          "app.kubernetes.io/name" = "anubis";
        };
      };
    }
  ];
}
