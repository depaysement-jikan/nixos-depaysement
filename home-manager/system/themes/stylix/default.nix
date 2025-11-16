{ lib, inputs, ... }: {
  options.myConfig.themes = {
    enable = lib.mkEnableOption "Enable Stylix configuration";

    stylix = { enable = lib.mkEnableOption "Enable stylix "; };
  };

  imports = [ ./stylix.nix inputs.stylix.homeModules.stylix ];
}
