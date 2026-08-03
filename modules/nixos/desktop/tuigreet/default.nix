{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  options.nixos-generic.desktop.tuigreet = {
    enable = lib.mkEnableOption "TUIGreet Display Manager";
  };

  config = lib.mkIf config.nixos-generic.desktop.tuigreet.enable {
    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          command = ''
            ${pkgs.tuigreet}/bin/tuigreet \
              --time \
              --remember \
              --remember-user-session \
              --cmd Hyprland
          '';
          user = "greeter";
        };
      };
    };
  };
}
