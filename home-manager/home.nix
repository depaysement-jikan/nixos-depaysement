# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  home = {
    stateVersion = "25.05";
    sessionPath = [ "$HOME/.local/bin" ];
  };
  imports = [ ./apps ./desktop ./system ];

  myHomeConfig = {
    apps = {
      enable = true;
      browsers.enable = true;
      web.enable = true;
    };
    desktop = {
      enable = true;
      rofi.enable = true;
      wofi.enable = true;
      hyprland.enable = true;
    };
    system = {
      enable = true;
      fonts.enable = true;
      theme.enable = true;
    };
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home = {
    username = "depaysement";
    homeDirectory = "/home/depaysement";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    vim
    wget
    neovim
    ghostty
    gcc
    git
    nodejs
    ripgrep
    fd
    fzf
    cargo
    unzip
    go
  ];

  # Enable home-manager and git
  programs = {
    home-manager.enable = true;
    git.enable = true;
    nh = { enable = true; };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  # system.stateVersion = "25.05";
}
