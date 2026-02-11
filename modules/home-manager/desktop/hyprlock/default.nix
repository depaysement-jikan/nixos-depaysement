{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.myHomeConfig.desktop.hyprlock;
in {
  options = {hyprlock.enable = lib.mkEnableOption "Enable Hyprlock";};

  config = lib.mkIf config.hyprlock.enable {
    programs.hyprlock = {
      enable = cfg.enable;
      settings = {
        general.hide_cursor = true;
        label = [
          {
            monitor = "";
            text = "$TIME";
            font_size = 120;
            font_family = "JetBrains Mono";
            color = "rgba(255, 255, 255, 0.8)";
            position = "0, 80";
            halign = "center";
            valign = "center";
            max_width = 800;
            wrap = false;
            padding = 10;
            background_color = "rgba(0, 0, 0, 0.3)";
            rounding = 8;
            fade_on_empty = false;
            visible = true;
          }
        ];

        input-field = {
          size = "300, 60";
          outline_thickness = 2;
          dots_size = 0.1;
          dots_spacing = 0.15;
          dots_center = true;
          dots_rounding = -1;
          font_family = "Noto Sans";
          placeholder_text = ''<i><span foreground="##ffffff99">🔒 Enter password</span></i>'';
          fade_on_empty = true;
          fade_timeout = 1500;
          hide_input = false;
          position = "0, -50";
          halign = "center";
          valign = "center";
          rounding = -1;
        };
      };
    };
  };
}
