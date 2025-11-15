{ inputs, pkgs, lib, config, ... }: {
  options = { theme.enable = lib.mkEnableOption "Enable theme module"; };
  imports = [ inputs.catppuccin.homeModules.catppuccin ];
  config = lib.mkIf config.zen.enable {
    home.packages = with pkgs; [ inputs.catppuccin ];
  };
}
