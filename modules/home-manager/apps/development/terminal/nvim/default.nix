{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {neovim.enable = lib.mkEnableOption "Enable neovim module";};
  config = lib.mkIf config.myHomeConfig.apps.development.terminal.neovim.enable {
    home.packages = with pkgs; [vim neovim lazygit];
  };
}
