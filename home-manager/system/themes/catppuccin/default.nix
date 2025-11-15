{ inputs, pkgs, lib, config, ... }:
let cfg = config.myHomeConfig.system.themes;
in {
  options = {
    themes.catppuccin.enable = lib.mkEnableOption "Enable theme module";
  };
  imports = [ inputs.catppuccin.homeModules.catppuccin ];
  config = lib.mkIf cfg.enable {
    catppuccin = {
      enable = true;
      flavor = "frappe";
      rofi = {
        enable = true;
        flavor = "frappe";
      };
    };
  };
}
