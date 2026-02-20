{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) types;
in {
  options.homelab.databases.cloudnative-pg = {
    enable = lib.mkOption {
      type = types.bool;
      default = true;
    };
  };

  config.services.k3s.manifests = {
    cnpg = {
      inherit (config.homelab.databases.cloudnative-pg) enable;
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/v1.24.4/releases/cnpg-1.24.4.yaml";
        sha256 = "1pg00s18gxxn9asxskgdg13yar1c96dd4zjzmm3932aimp334knd";
      };
    };

    cnpg-image-catalog = {
      inherit (config.homelab.databases.cloudnative-pg) enable;
      content = {
        apiVersion = "postgresql.cnpg.io/v1";
        kind = "ClusterImageCatalog";
        metadata.name = "postgresql";
        spec.images = [
          {
            major = 15;
            image = "ghcr.io/cloudnative-pg/postgresql:15.10";
          }
          {
            major = 16;
            image = "ghcr.io/cloudnative-pg/postgresql:16.6";
          }
          {
            major = 17;
            image = "ghcr.io/cloudnative-pg/postgresql:17.2";
          }
        ];
      };
    };
  };
}
