{
  outputs,
  config,
  settings,
  inputs,
  ...
}: {
  home = {
    stateVersion = "25.11";
    sessionPath = ["$HOME/.local/bin"];
    sessionVariables = {EDITOR = "nvim";};
  };
  imports = [
    ./apps
    ./desktop
    ./system
    ./scripts
    ./hardware
    ./misc
    inputs.sops-nix.homeManagerModules.sops
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

  home = {
    username = settings.user;
    homeDirectory = "/home/${settings.user}";
  };

  services.swaync.enable = true;

  programs = {
    wlogout.enable = true;
    kitty.enable = true;
    home-manager.enable = config.homeManager.enable;
    bash.enable = true;
    nh = {enable = true;};
  };

  home.file.".face.icon" = {
    source = ./pfp/image.png;
  };

  xdg.configFile."git/config".force = true;

  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  # system.stateVersion = "25.05";
}
