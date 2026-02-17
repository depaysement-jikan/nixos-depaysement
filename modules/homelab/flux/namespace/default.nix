_: {
  services.k3s.manifests.flux-system-namespace.content = [
    {
      apiVersion = "v1";
      kind = "Namespace";
      metadata = {
        labels = {
          "app.kubernetes.io/instance" = "flux-system";
          "app.kubernetes.io/name" = "flux-system";
        };
        name = "flux-system";
      };
    }
  ];
}
