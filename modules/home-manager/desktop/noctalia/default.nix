{
  inputs,
  lib,
  config,
  settings,
  pkgs,
  ...
}: {
  options = {noctalia.enable = lib.mkEnableOption "Enable noctalia";};
  imports = [
    inputs.noctalia.homeModules.default
  ];
  config = lib.mkIf config.homeManager.desktop.noctalia.enable {
    home.packages = with pkgs; [mpvpaper];
    programs.noctalia = {
      enable = true;
      package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      systemd.enable = true;
      settings = {
        shell = {
          polkit_agent = true;
          avatar_path = "/home/${settings.user}/.nixos-dotfiles/modules/home-manager/pfp/image.png";
        };
        wallpaper = {
          enabled = false;
        };
        bar = {
          order = ["default"];
          default = {
            position = "top";
            radius = 24;
            concave_edge_corners = false;
            background_opacity = 0.9;
            border_width = 1;
            padding = 24;
            scale = 1.1;
            widget_spacing = 24;
            start = [
              "clock"
              "session"
              "volume"
              "network"
              "weather"
              "control-center"
              "nightwatch75/file-search:file-search"
            ];
            center = ["workspaces"];
            end = ["davemhammer/tailscale:status" "media" "tray" "notifications"];
          };
        };
        notification = {
          enable_daemon = true;
        };
        idle.behavior = {
          lock = {
            enabled = true;
            timeout = 300;
            action = "lock";
          };
          "screen-off" = {
            enabled = true;
            timeout = 360;
            action = "screen_off";
          };
          suspend = {
            enabled = true;
            timeout = 900;
            action = "suspend";
          };
        };
        colorSchemes.predefinedScheme = "Monochrome";
        widget = {
          workspaces = {
            style = "regular";
            show_labels = false;
            pill_scale = 1.5;
            inactive_pill_size = 1.75;
            active_pill_size = 2.5;
            hide_when_empty = false;
            capsule = false;
          };
          battery = {
            show_label = true;
            warning_color = "error";
            capsule_fill = "surface_variant";
          };
          network = {
            show_label = true;
            color = "tertiary";
            capsule_fill = "surface_variant";
          };
          volume = {
            device = "output";
            show_label = true;
            color = "secondary";
            mute_color = "error";
            capsule_fill = "surface_variant";
          };
          session = {
            color = "primary";
          };
          media = {
            color = "secondary";
            hide_artist = true;
            max_length = 150;
            art_size = 24;
          };
          brightness = {
            show_label = true;
            capsule_fill = "surface_variant";
          };
          control-center = {
            custom_image = "/home/${settings.user}/.nixos-dotfiles/modules/home-manager/pfp/image.png";
          };
          clipboard.capsule_fill = "surface_variant";
          screenshot.capsule_fill = "surface_variant";
          notifications.capsule_fill = "surface_variant";
        };
        location = {
          auto_locate = true;
        };
        plugins = {
          enabled = [
            "noctalia/screen_recorder"
            "noctalia/bitwarden"
            "cleboost/ssh-launcher"
            "oldirtty/color_picker"
            "nightwatch75/file-search"
            "davemhammer/tailscale"
          ];
        };
        plugin_settings."noctalia/screen_recorder" = {
          video_source = "focused";
        };
      };
    };
  };
}
