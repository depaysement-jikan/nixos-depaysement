{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {sh.enable = lib.mkEnableOption "Enable sh module";};
  config = lib.mkIf config.myHomeConfig.apps.development.languages.sh.enable {
    home.packages = with pkgs; [shfmt bash-language-server];
  };
}
