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
}
