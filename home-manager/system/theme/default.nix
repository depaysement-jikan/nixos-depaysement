{ inputs, pkgs, lib, config, ... }:
let cfg = config.myHomeConfig.system.theme;
in {
  options = { theme.enable = lib.mkEnableOption "Enable theme module"; };
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
