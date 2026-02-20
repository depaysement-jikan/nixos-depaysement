{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [rclone];
  sops.templates.rclone = {
    content = ''
      [Namishiro]
      type = s3
      provider = Cloudflare
      access_key_id = ${config.sops.placeholder.fluxAccessKeyId}
      secret_access_key = ${config.sops.placeholder.fluxSecretKey}
      region = auto
      endpoint = https://${config.sops.placeholder.fluxEndpoint}
    '';
    path = "/etc/rclone.conf";
  };

  systemd.services.flux-s3-sync = {
    description = "Sync Nix-generated manifests to S3 for Flux";

    wantedBy = ["multi-user.target"];

    wants = ["network-online.target"];
    after = ["network-online.target"];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };

    script = ''
      ${pkgs.rclone}/bin/rclone sync ${config.services.k3s.manifestDir} Namishiro:${config.homelab.flux.bucketName} \
        --config /etc/rclone.conf \
        --checksum \
        --verbose \
        --copy-links \
        --s3-no-check-bucket
    '';
  };
}
