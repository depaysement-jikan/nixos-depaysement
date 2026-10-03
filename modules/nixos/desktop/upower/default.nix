{
  config,
  lib,
  ...
}: {
  options.nixos-generic.desktop.upower = {
    enable = lib.mkEnableOption "Upower module";
  };

  config = lib.mkIf config.nixos-generic.desktop.upower.enable {
    services.upower.enable = true;
  };
}
