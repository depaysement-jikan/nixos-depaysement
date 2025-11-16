{ inputs, pkgs, lib, config, ... }:
let cfg = config.myHomeConfig.system.themes.catppuccin;
in {
  options = {
    themes.catppuccin.enable = lib.mkEnableOption "Enable theme module";
  };
  imports = [ inputs.catppuccin.homeModules.catppuccin ];
  config = {
    catppuccin = {
      enable = cfg.enable;
      flavor = "frappe";
      rofi = {
        enable = cfg.enable;
        flavor = "frappe";
      };
      firefox = {
        enable = cfg.enable;
        flavor = "latte";
      };
    };
  };
}
