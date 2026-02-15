{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  themes = {
    catppuccin-frappe = "catppuccin-frappe";
    oxocarbon-dark = "oxocarbon-dark";
    tokyo-night-moon = "tokyo-night-moon";
    tokyo-night-dark = "tokyo-night-dark";
    tokyo-night-storm = "tokyo-night-storm";
  };
  cfg = config.myHomeConfig.system.themes.stylix;
in {
  config = {
    stylix = {
      enable = cfg.enable;
      autoEnable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${themes.catppuccin-frappe}.yaml";
      cursor = {
        name = "macOS";
        package = pkgs.apple-cursor;
        size = 36;
      };
      image = ./../../../wallpapers/preview_5.png;
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
        applications = 0.85;
        terminal = 0.85;
        desktop = 0.85;
        popups = 0.85;
      };
      polarity = "dark";
      targets = {
        nixos-icons.enable = true;
        waybar.enable = false;
      };
    };
  };
}
