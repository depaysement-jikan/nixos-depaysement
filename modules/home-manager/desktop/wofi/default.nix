{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {wofi.enable = lib.mkEnableOption "Enable wofi";};
  config = lib.mkIf config.homeManager.desktop.wofi.enable {
    home = {packages = with pkgs; [wofi];};

    xdg.configFile = {
      "wofi/config" = {
        text = ''
          width=600
          height=500
          location=center
          show=drun
          prompt=Apps
          filter_rate=100
          allow_markup=true
          no_actions=true
          halign=fill
          orientation=vertical
          content_halign=fill
          insensitive=true
          allow_images=true
          image_size=40
          gtk_dark=true
        '';
      };
      "wofi/style.css" = {
        text = ''
          window {
          margin: 0px;
          border: 1px solid #d8dee9;
          border-radius: 1rem;
          background-color: rgba(46, 52, 64, 0.5);
          }

          #input {
          margin: 5px;
          border: none;
          color: #d8dee9;
          background-color: rgba(46, 52, 64, 0.5);
          }

          #inner-box {
          margin: 5px;
          border: none;
          background-color: rgba(46, 52, 64, 0.5);
          }

          #outer-box {
          margin: 5px;
          border: none;
          background-color: rgba(46, 52, 64, 0.5);
          }

          #scroll {
          margin: 0px;
          border: none;
          }

          #text {
          margin: 5px;
          border: none;
          color: #d8dee9;
          }

          #entry:selected {
          background-color: #3b4252;
          }
        '';
      };
    };
  };
}
