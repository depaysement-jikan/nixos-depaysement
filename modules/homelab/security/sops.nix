{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  environment.systemPackages = builtins.attrValues {inherit (pkgs) age sops;};

  sops = {
    defaultSopsFile = ../secrets.yaml;
    age = {
      sshKeyPaths = ["/var/lib/sops-nix/.ssh/homelab"];
      # Instructions:
      # mkdir -p /var/lib/sops-nix/age
      # age-keygen -o /var/lib/sops-nix/age/keys.txt
      # Fill in your secrets in YAML format
      # sudo sops --encrypt  --in-place --age $(sudo age-keygen -y /var/lib/sops-nix/age/key.txt) ~/.nixos-dotfiles/modules/homelab/secrets.yaml
      # home-manager switch --flake .
      keyFile = "/var/lib/sops-nix/age/key.txt";
    };
    secrets = {
      fluxAccessKey = {};
      fluxAccessKeyId = {};
      fluxSecretKey = {};
      fluxDiscordWebhookUrl = {};
      fluxEndpoint = {};
      piholePassword = {
        sopsFile = ../pihole-secrets.yaml;
      };
      certEmail = {
        sopsFile = ../cert-secrets.yaml;
      };
      tailscaleAuthKey = {
        sopsFile = ../tailscale-secrets.yaml;
      };
      tailscaleApiKey = {
        sopsFile = ../tailscale-secrets.yaml;
      };
    };
  };
}
