{
  config,
  lib,
  pkgs,
  ...
}: {
  options.nixos-generic.desktop.audio.enable = lib.mkEnableOption "Audio settings";
  config = lib.mkIf config.nixos-generic.desktop.audio.enable {
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        wireplumber.enable = true;
        pulse.enable = true;
        jack.enable = true;
        audio.enable = true;
      };
    };
    environment.systemPackages = [pkgs.pavucontrol];
  };
}
