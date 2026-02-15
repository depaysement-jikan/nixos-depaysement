{...}: ''
    @define-color background #1e1e2e;
    @define-color foreground #cdd6f4;
    @define-color select     #585b70;

    @define-color pink       #f5c2e7;
    @define-color pink-soft  rgba(245, 194, 231, 0.1);
    @define-color purple     #cba6f7;
    @define-color red        #f38ba8;
    @define-color orange     #fab387;
    @define-color yellow     #f9e2af;
    @define-color green      #a6e3a1;
    @define-color blue       #89b4fa;
    @define-color gray       #45475a;

  * {
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 12px;
    font-weight: bold;
    background-color: transparent;
    border-radius: 5px;
    min-height: 0;
  }

  window,
  tooltip {
    background-color: @background;
  }

  #waybar {
    background: transparent;
    border-radius: 0;
  }

  .modules-center {
    background: @background;
    padding: 8px 16px;
    border-radius: 28px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
    margin-top: 5px;
    margin-bottom: 5px;
    min-width: 80px;
  }

  #workspaces {
    margin: 1px 0;
  }

  #workspaces button {
    color: @foreground;
    margin: 1.5px;
    border: none;
    transition: color 0.2s ease, border-bottom 0.2s ease, padding 0.2s ease;
  }

  #workspaces button:hover {
    color: @pink;
    background: @pink-soft;
  }

  #workspaces button.active {
    color: @background;
    background: linear-gradient(135deg, @blue 0%, @purple 50%, @pink 100%);
  }

  #workspaces button.urgent {
    background-color: @red;
    color: @background;
  }

  #custom-power,
  #tray,
  #bluetooth,
  #network,
  #battery,
  #pulseaudio,
  #clock {
    color: @foreground;
    margin: 1px 0;
    padding: 0 10px;
    background: transparent;
    transition: background-color 0.2s ease;
  }

  #custom-power:hover,
  #bluetooth:hover,
  #network:hover,
  #battery:hover,
  #pulseaudio:hover,
  #clock:hover {
    background-color: rgba(88, 91, 112, 0.6); /* alpha of --select */
    border-radius: 3px;
  }

  #bluetooth {
    color: @yellow;
  }

  #network {
    color: @green;
  }

  #battery {
    color: @purple;
  }

  #pulseaudio {
    color: @orange;
  }

  #clock {
    margin-right: 10px;
    color: @blue;
  }

  #custom-power {
    margin-left: 10px;
    padding: 0 10px 0 15px;
  }
''
