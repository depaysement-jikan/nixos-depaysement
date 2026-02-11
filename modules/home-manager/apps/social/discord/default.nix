{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {discord.enable = lib.mkEnableOption "Enable discord module";};
  config = lib.mkIf config.myHomeConfig.apps.social.discord.enable {
    home.packages = with pkgs; [discord];
  };
}
