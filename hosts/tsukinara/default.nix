# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  sddm-theme = inputs.silentSDDM.packages.${pkgs.system}.default;
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/homelab
    ./disko
    ./security/sops.nix
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
    };
    channel.enable = false;

    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tsukinara";
  networking.networkmanager.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [4200 3000];
    trustedInterfaces = ["cni0" "flannel.1"];
  };
  networking.networkmanager.dns = "none";

  networking.nameservers = [
    "192.168.1.204"
    "1.1.1.1"
  ];

  time.timeZone = "America/Chicago";

  environment.shells = with pkgs; [zsh git];

  users.users.depaysement = {
    isNormalUser = true;
    extraGroups = ["wheel" "k3s" "sddm"];
    packages = with pkgs; [tree kitty];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.depaysementUserPassword.path;
    homeMode = "711";
  };

  programs.firefox.enable = true;
  programs.zsh.enable = true;
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [ghostty home-manager sddm-theme bind];

  services.displayManager.sddm = {
    # To make pfp show up
    # chmod o+x ~
    enable = true;
    wayland.enable = true;
    enableHidpi = true;
    theme = sddm-theme.pname;
    package = pkgs.kdePackages.sddm;
    extraPackages = sddm-theme.propagatedBuildInputs;

    settings = {
      Wayland = {EnableHiDPI = true;};
      General = {
        GreeterEnvironment = "QML2_IMPORT_PATH=${sddm-theme}/share/sddm/themes/${sddm-theme.pname}/components/,QT_IM_MODULE=qtvirtualkeyboard";
        InputMethod = "qtvirtualkeyboard";
      };
    };
  };

  services.openssh = {enable = true;};
  services.blueman.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  system.stateVersion = "25.11";
}
