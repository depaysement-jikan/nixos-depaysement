{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {cli.enable = lib.mkEnableOption "Enable misc cli module";};
  config = lib.mkIf config.homeManager.misc.cli.enable {
    home.packages = with pkgs; [cbonsai lolcat fastfetch htop];
  };
}
