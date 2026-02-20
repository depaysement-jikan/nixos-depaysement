# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  outputs,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  home = {
    stateVersion = "25.11";
    sessionPath = ["$HOME/.local/bin"];
    sessionVariables = {EDITOR = "nvim";};
  };
  imports = [./apps ./desktop ./system ./security ./scripts];

  myHomeConfig = {
    apps = {
      enable = true;
      browsers = {
        enable = true;
        zen.enable = true;
        firefox.enable = true;
        floorp.enable = true;
      };
      social = {
        enable = true;
        discord.enable = true;
        whatsapp.enable = true;
      };
      gaming = {
        enable = true;
        steam.enable = true;
        gamescope.enable = true;
      };
      productivity = {
        enable = true;
        obsidian.enable = true;
      };
      development = {
        enable = true;
        terminal = {
          enable = true;
          yazi.enable = true;
          zsh.enable = true;
          nushell.enable = true;
          tmux.enable = true;
          git.enable = true;
          ghostty.enable = true;
          neovim.enable = true;
          starship.enable = true;
        };
        api-clients = {
          enable = true;
          yaak.enable = true;
        };
        languages = {
          enable = true;
          go.enable = true;
          node.enable = true;
          markdown.enable = true;
          nix-lang.enable = true;
          sh.enable = true;
          c.enable = true;
          typescript.enable = true;
          lua.enable = true;
          python.enable = true;
          rust.enable = true;
        };
        ai = {
          enable = true;
          crush.enable = true;
        };
        db = {
          enable = true;
          postgres.enable = true;
        };
      };
    };
    desktop = {
      enable = true;
      rofi.enable = false;
      wofi.enable = true;
      hyprland.enable = true;
      hyprlock.enable = true;
      waybar.enable = true;
    };
    system = {
      enable = true;
      fonts.enable = true;
      themes = {
        enable = true;
        catppuccin.enable = false;
        stylix.enable = true;
      };
      clipboard.enable = true;
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
  home.packages = with pkgs; [wget swaynotificationcenter cbonsai lolcat fastfetch];
  services.swaync.enable = true;

  # Enable home-manager and git
  programs = {
    wlogout.enable = true;
    home-manager.enable = true;
    bash.enable = true;
    nh = {enable = true;};
  };

  home.file = {".face.icon" = {source = ./pfp/image.png;};};

  xdg.configFile."git/config".force = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  # system.stateVersion = "25.05";
}
