{ inputs, config, lib, pkgs, ... }:

let
  themes = {
    catppuccin-frappe = "catppuccin-frappe";
    oxocarbon-dark = "oxocarbon-dark";
    tokyo-night-moon = "tokyo-night-moon";
    tokyo-night-dark = "tokyo-night-dark";
    tokyo-night-storm = "tokyo-night-storm";
  };
  cfg = config.myHomeConfig.system.themes;
in {
  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = true;
      base16Scheme =
        "${pkgs.base16-schemes}/share/themes/${themes.catppuccin-frappe}.yaml";
      cursor = {
        name = "macOS";
        package = pkgs.apple-cursor;
        size = 36;
      };
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
        sizes = {
          applications = 11;
          terminal = 12;
          desktop = 11;
          popups = 11;
        };
      };
      opacity = {
        applications = 1.0;
        terminal = 0.95;
        desktop = 1.0;
        popups = 1.0;
      };
      polarity = "dark";
      targets = { nixos-icons.enable = true; };
    };
  };
}
