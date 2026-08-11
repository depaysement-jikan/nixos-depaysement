{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./users
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = ["nix-command" "flakes" "pipe-operators"];
      flake-registry = "";
      nix-path = config.nix.nixPath;
      extra-substituters = ["https://noctalia.cachix.org"];
      extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
    };
    channel.enable = false;

    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  boot.loader.limine.enable = false;
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    consoleMode = "max";
  };
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  networking.hostName = "shinobu";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [4200 3000];
    trustedInterfaces = ["cni0" "flannel.1"];
  };
  networking.networkmanager.dns = "none";

  networking.nameservers = [
    "1.1.1.1"
  ];

  time.timeZone = "America/Chicago";

  environment.shells = with pkgs; [nushell];

  environment.systemPackages = with pkgs; [bind git efibootmgr];
  programs.zsh.enable = true;

  services.openssh = {enable = true;};
  services.blueman.enable = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  system.stateVersion = "25.11";
}
