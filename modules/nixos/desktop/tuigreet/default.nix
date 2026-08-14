{
  config,
  pkgs,
  lib,
  ...
}: {
  options.nixos-generic.desktop.tuigreet = {
    enable = lib.mkEnableOption "TUIGreet Display Manager";
  };

  config = lib.mkIf config.nixos-generic.desktop.tuigreet.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = lib.concatStringsSep " " [
            "${pkgs.tuigreet}/bin/tuigreet"
            "--time"
            "--remember"
            "--remember-user-session"
            "--cmd ${lib.getExe' config.programs.hyprland.package "start-hyprland"}"
          ];
          user = "greeter";
        };
      };
    };
  };
}
