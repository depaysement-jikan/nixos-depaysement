{
  lib,
  config,
  ...
}: {
  imports = [./yazi ./zsh ./nushell ./tmux ./git ./ghostty ./nvim ./starship];

  options = {terminal.enable = lib.mkEnableOption "Enable terminal module";};
  config = lib.mkIf config.myHomeConfig.apps.development.terminal.enable {
    yazi.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
    nushell.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;
    ghostty.enable = lib.mkDefault true;
    starship.enable = lib.mkDefault true;
  };
}
