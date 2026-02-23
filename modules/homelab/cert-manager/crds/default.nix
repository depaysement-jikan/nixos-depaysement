{pkgs, ...}: {
  config.services.k3s = {
    manifests."cert-manager-crds".source = pkgs.fetchurl {
      url = "https://github.com/cert-manager/cert-manager/releases/download/v1.19.3/cert-manager.crds.yaml";
      sha256 = "sha256-aeDxoTaQjjFt5HBuafA/7vb4FcA0ggQj8kF117YkkHU=";
    };
  };
}
