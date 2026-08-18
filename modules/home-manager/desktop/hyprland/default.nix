{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {hyprland.enable = lib.mkEnableOption "Enable hyprland";};
  config = lib.mkIf config.homeManager.desktop.hyprland.enable {
    home.packages = with pkgs; [
      kitty
      grim
      ffmpeg_6
      pavucontrol
      playerctl
      mpv
      wl-clipboard
      slurp
      swappy
      satty
      (writeShellScriptBin "screenshot" ''
        grim -g "$(slurp)" - \
          | satty --filename - --copy-command wl-copy
      '')
      (writeShellScriptBin "screenshot-edit" ''
        grim -g "$(slurp)" - | wl-copy
      '')
    ];
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      systemd.variables = ["--all"];
      xwayland = {enable = true;};
      settings = {
        "$mainMod" = "SUPER";
        env = ["ELECTRON_OZONE_PLATFORM_HINT,auto"];

        xwayland = {force_zero_scaling = true;};
        input = {
          kb_options = "caps:escape";
          follow_mouse = 1;
          mouse_refocus = false;
          accel_profile = "flat";
          force_no_accel = false;
          touchpad = {natural_scroll = 1;};
        };

        cursor = {
          enable_hyprcursor = true;
          no_hardware_cursors = true;
        };

        general = {
          gaps_in = 7;
          gaps_out = 7;
          border_size = 2;
          layout = "dwindle";
        };

        decoration = {
          rounding = 12;
          shadow = {
            enabled = false;
            range = 20;
            render_power = 1;
          };
          blur = {
            enabled = true;
            size = 4;
            passes = 2;
            new_optimizations = true;
            ignore_opacity = true;
            noise = 1.17e-2;
            contrast = 1.3;
            brightness = 1;
            xray = false;
          };
        };

        animations = {
          enabled = true;
          animation = [
            "global, 1, 10, default"
            "border, 1, 5.39, easeOutQuint"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin"
            "windowsOut, 1, 1.49, easeInBack, popin"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "fade, 1, 3.03, quick"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "workspaces, 1, 1.94, almostLinear, fade"
            "workspacesIn, 1, 1.21, almostLinear, fade"
            "workspacesOut, 1, 1.94, almostLinear, fade"
          ];
          bezier = [
            "easeOutQuint,0.23,1,0.32,1"
            "easeInBack,0.36,0,0.66,-0.56"
            "easeInOutCubic,0.65,0.05,0.36,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];
        };

        misc = {
          vrr = 0;
          disable_hyprland_logo = true;
        };

        dwindle = {
          force_split = 0;
          preserve_split = true;
          default_split_ratio = 1.0;
          special_scale_factor = 0.8;
          split_width_multiplier = 1.0;
          use_active_for_splits = true;
        };

        debug = {
          damage_tracking = 2;
          vfr = true;
        };

        exec-once = [
          "[workspace 1 silent] foot"
          "[workspace 2 silent] helium"
          "[workspace 3 silent] discord"
          # "[workspace 4 silent] whatsapp-electron"
          "[workspace 5 silent] spotify"
          "clipse -listen"
        ];

        windowrule = [
          "match:class ^(com.mitchellh.ghostty)$, opacity 0.95 0.95"

          "match:class ^(file_progress)$, float on"
          "match:class ^(confirm)$, float on"
          "match:class ^(dialog)$, float on"
          "match:class ^(download)$, float on"
          "match:class ^(notification)$, float on"
          "match:class ^(error)$, float on"
          "match:class ^(confirmreset)$, float on"

          "match:title ^(Open File)$, float on"
          "match:title ^(branchdialog)$, float on"
          "match:title ^(Confirm to replace files)$, float on"
          "match:title ^(File Operation Progress)$, float on"
          "match:title ^(mpv)$, float on"

          "match:class ^(discord)$, workspace 3"

          # Clipse
          "match:title ^(clipse)$, float on"
          "match:title ^(clipse)$, size 622 652"
          "match:title ^(clipse)$, center on"

          # Pavucontrol
          "match:class ^(org.pulseaudio.pavucontrol)$, float on"
          "match:class ^(org.pulseaudio.pavucontrol)$, center on"
          "match:class ^(org.pulseaudio.pavucontrol)$, size 622 652"
        ];

        bind = [
          # Kill, Exit, float, group
          "$mainMod,Q,killactive,"
          "$mainMod,M,exit,"
          "$mainMod,S,togglefloating,"
          "$mainMod,g,togglegroup"

          # Vim bindings
          "$mainMod,h,movefocus,l"
          "$mainMod,l,movefocus,r"
          "$mainMod,k,movefocus,u"
          "$mainMod,j,movefocus,d"
          "$mainMod,left,movefocus,l"
          "$mainMod,down,movefocus,d"
          "$mainMod,up,movefocus,u"
          "$mainMod,right,movefocus,r"

          # Workspace switching
          "$mainMod,1,workspace,1"
          "$mainMod,2,workspace,2"
          "$mainMod,3,workspace,3"
          "$mainMod,4,workspace,4"
          "$mainMod,5,workspace,5"
          "$mainMod,6,workspace,6"
          "$mainMod,7,workspace,7"
          "$mainMod,8,workspace,8"

          # Window movement
          "$mainMod SHIFT, H, movewindow, l"
          "$mainMod SHIFT, L, movewindow, r"
          "$mainMod SHIFT, K, movewindow, u"
          "$mainMod SHIFT, J, movewindow, d"
          "$mainMod SHIFT, left, movewindow, l"
          "$mainMod SHIFT, right, movewindow, r"
          "$mainMod SHIFT, up, movewindow, u"
          "$mainMod SHIFT, down, movewindow, d"
          "$mainMod, T, layoutmsg, togglesplit"

          # Workspace movement
          "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
          "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
          "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
          "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
          "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
          "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
          "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
          "$mainMod SHIFT, 8, movetoworkspacesilent, 8"

          # Program shortcuts
          "$mainMod,RETURN,exec,foot"
          "$mainMod,b,exec,helium"
          "$mainMod,d,exec,discord"
          ",Print,exec,screenshot-edit"
          "$mainMod,Print,exec,screenshot"
          "CTRL,Print,exec,grim -o DP-1 ~/Pictures/screenshot.png"
          "$mainMod,o,exec,obsidian"
          "$mainMod,i,exec,idea-ultimate"
          "$mainMod,z,exec,noctalia-shell"
          "$mainMod,space,exec,pkill wofi || wofi drun"
          "CTRL&ALT,DELETE,exec,hyprlock"
          "$mainMod, V, exec, ghostty --title=clipse -e clipse"
          "$mainMod, escape, exec, wlogout -b 5"

          # Audio
          ",XF86AudioRaiseVolume,exec,wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute,exec,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioMicMute,exec,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ];

        bindm = ["$mainMod,mouse:272,movewindow" "$mainMod,mouse:273,resizewindow"];

        ecosystem = {no_update_news = true;};
      };
    };
  };
}
