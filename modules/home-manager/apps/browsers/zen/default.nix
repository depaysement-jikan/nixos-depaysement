{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  options = {zen.enable = lib.mkEnableOption "Enable zen module";};
  config = lib.mkIf config.homeManager.apps.browsers.zen.enable {
    home.packages = with pkgs; [inputs.zen-browser.packages."${system}".twilight];
  };
}
