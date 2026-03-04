{lib, ...}: {
  options.homeManager.enable = lib.mkEnableOption "Enable home manager";
  config = {
    homeManager = {
      enable = true;
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
            json.enable = true;
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
      hardware = {
        enable = true;
        qmk.enable = true;
      };
    };
  };
}
