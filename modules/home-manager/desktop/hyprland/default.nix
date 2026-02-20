{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {hyprland.enable = lib.mkEnableOption "Enable hyprland";};
  config = lib.mkIf config.hyprland.enable {
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
      wl-clipboard
      satty
      (writeShellScriptBin "screenshot" ''
        grim -g "$(slurp)" - \
          | satty --filename - --copy-command wl-copy
      '')
      (writeShellScriptBin "screenshot-edit" ''
        grim -g "$(slurp)" - | wl-copy
      '')
      (writeShellScriptBin "autostart-waybar" ''
        pkill waybar
        waybar -c $HOME/.config/waybar/config -s $HOME/.config/waybar/style.css &
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
          rounding = 10;
          shadow = {
            enabled = false;
            ignore_window = true;
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
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
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
            "easeInOutCubic,0.65,0.05,0.36,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];
        };
        misc = {
          vfr = true;
          vrr = 0;
          disable_hyprland_logo = true;
        };

        dwindle = {
          pseudotile = true;
          force_split = 0;
          preserve_split = true;
          default_split_ratio = 1.0;
          special_scale_factor = 0.8;
          split_width_multiplier = 1.0;
          use_active_for_splits = true;
        };

        master = {
          mfact = 0.5;
          orientation = "right";
          special_scale_factor = 0.8;
          new_status = "slave";
        };

        debug = {damage_tracking = 2;};

        exec-once = [
          "[workspace 1 silent] ghostty"
          "[workspace 2 silent] firefox"
          "[workspace 3 silent] discord"
          "[workspace 4 silent] whatsapp-electron"
          "clipse -listen"
        ];

        windowrulev2 = [
          "float,class:^(pavucontrol)$"
          "float,class:^(file_progress)$"
          "float,class:^(confirm)$"
          "float,class:^(dialog)$"
          "float,class:^(download)$"
          "float,class:^(notification)$"
          "float,class:^(error)$"
          "float,class:^(confirmreset)$"
          "float,title:^(Open File)$"
          "float,title:^(branchdialog)$"
          "float,title:^(Confirm to replace files)$"
          "float,title:^(File Operation Progress)$"
          "float,title:^(mpv)$"
          "workspace 3, class:^(discord)$"
          "opacity 1.0 1.0,class:^(wofi)$"
          "float,title:^(clipse)$"
          "size 622 652,title:^(clipse)$"
          "center,title:^(clipse)$"
        ];

        bind = [
          # Kill, Exit, float, group
          "SUPER,Q,killactive,"
          "SUPER,M,exit,"
          "SUPER,S,togglefloating,"
          "SUPER,g,togglegroup"

          # Vim bindings
          "SUPER,h,movefocus,l"
          "SUPER,l,movefocus,r"
          "SUPER,k,movefocus,u"
          "SUPER,j,movefocus,d"
          "SUPER,left,movefocus,l"
          "SUPER,down,movefocus,d"
          "SUPER,up,movefocus,u"
          "SUPER,right,movefocus,r"

          # Workspace switching
          "SUPER,1,workspace,1"
          "SUPER,2,workspace,2"
          "SUPER,3,workspace,3"
          "SUPER,4,workspace,4"
          "SUPER,5,workspace,5"
          "SUPER,6,workspace,6"
          "SUPER,7,workspace,7"
          "SUPER,8,workspace,8"

          # Window movement
          "SUPER SHIFT, H, movewindow, l"
          "SUPER SHIFT, L, movewindow, r"
          "SUPER SHIFT, K, movewindow, u"
          "SUPER SHIFT, J, movewindow, d"
          "SUPER SHIFT, left, movewindow, l"
          "SUPER SHIFT, right, movewindow, r"
          "SUPER SHIFT, up, movewindow, u"
          "SUPER SHIFT, down, movewindow, d"
          "SUPER, T, togglesplit"

          # Workspace movement
          "SUPER $mainMod SHIFT, 1, movetoworkspacesilent, 1"
          "SUPER $mainMod SHIFT, 2, movetoworkspacesilent, 2"
          "SUPER $mainMod SHIFT, 3, movetoworkspacesilent, 3"
          "SUPER $mainMod SHIFT, 4, movetoworkspacesilent, 4"
          "SUPER $mainMod SHIFT, 5, movetoworkspacesilent, 5"
          "SUPER $mainMod SHIFT, 6, movetoworkspacesilent, 6"
          "SUPER $mainMod SHIFT, 7, movetoworkspacesilent, 7"
          "SUPER $mainMod SHIFT, 8, movetoworkspacesilent, 8"

          # Program shortcurts
          "SUPER,RETURN,exec,ghostty"
          "SUPER,b,exec,firefox"
          "SUPER,d,exec,discord"
          ",Print,exec,screenshot"
          "SUPER,Print,exec,screenshot-edit"
          "CTRL,Print,exec,grim -o DP-1 ~/Pictures/screenshot.png"
          "SUPER,o,exec,obsidian"
          "SUPER,i,exec,idea-ultimate"
          "SUPER,z,exec,waybar"
          "SUPER,space,exec,wofi -show drun"
          "CTRL&ALT,DELETE,exec,hyprlock"
          "SUPER, V, exec, ghostty --title=clipse -e clipse"
          "SUPER, escape, exec, wlogout -b 5"
        ];

        bindm = ["SUPER,mouse:272,movewindow" "SUPER,mouse:273,resizewindow"];

        ecosystem = {no_update_news = true;};
      };
    };
  };
}
