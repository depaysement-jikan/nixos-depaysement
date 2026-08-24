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

  systemd.coredump.settings.Coredump = {
    ProcessSizeMax = "2G";
    ExternalSizeMax = "2G";
  };

  boot.loader.limine.enable = false;
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    consoleMode = "max";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl."kernel.sysrq" = 1;
  boot.kernel.sysctl."kernel.hung_task_timeout_secs" = 30;
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.initrd.kernelModules = ["amdgpu"];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  security.polkit.enable = true;

  # Temporary: swap entries were corrupting and taking the kernel down.
  # Partition stays in disko; remove these two lines to restore.
  systemd.suppressedSystemUnits = ["dev-nvme0n1p3.swap"];
  swapDevices = lib.mkForce [];
  boot.resumeDevice = lib.mkForce "";
  # boot.kernelParams = ["page_poison=1" "slub_debug=FZP" "page_owner=on"];
  boot.kernel.sysctl."kernel.io_uring_disabled" = 2;
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=force"
    "iommu.strict=1"
    "iommu.passthrough=0"
    "page_poison=1"
    "slub_debug=FZP"
    "page_owner=on"
  ];
  boot.kernel.sysctl."kernel.panic_on_oops" = 1;
  boot.kernel.sysctl."kernel.panic" = 10;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.amdgpu.initrd.enable = lib.mkDefault true;
  services.xserver.videoDrivers = lib.mkDefault ["modesetting"];
  # Temporary: swap entries were corrupting and taking the kernel down.
  # Partition stays in disko; remove these two lines to restore.

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

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

  services.openssh = {enable = true;};
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [bind git efibootmgr];

  programs.zsh.enable = true;

  system.stateVersion = "26.05";
}
