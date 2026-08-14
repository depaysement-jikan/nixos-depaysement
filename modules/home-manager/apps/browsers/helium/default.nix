{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options = {helium.enable = lib.mkEnableOption "Enable helium module";};
  config = lib.mkIf config.homeManager.apps.browsers.helium.enable {
    home.packages = [inputs.helium.packages.${pkgs.system}.default];
  };
}
