{config, ...}: {
  services.k3s.manifests."metallb-IPAddressPool".content = [
    {
      apiVersion = "metallb.io/v1beta1";
      kind = "IPAddressPool";
      metadata = {
        name = "k3s-nuc-pool";
        namespace = "metallb-system";
      };
      spec = {
        addresses = config.homelab.metallb.addresses;
      };
    }
  ];
}
