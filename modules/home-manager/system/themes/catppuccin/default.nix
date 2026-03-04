{
  inputs,
  config,
  ...
}: let
  cfg = config.homeManager.system.themes.catppuccin;
in {
  imports = [inputs.catppuccin.homeModules.catppuccin];
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
