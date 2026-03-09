{
  lib,
  pkgs,
  config,
  ...
}: {
  options = {fonts.enable = lib.mkEnableOption "Enable fonts module";};
  config = lib.mkIf config.homeManager.system.fonts.enable {
    home = {
      packages = with pkgs; [nerd-fonts.jetbrains-mono maple-mono.NF];
    };
  };
}
