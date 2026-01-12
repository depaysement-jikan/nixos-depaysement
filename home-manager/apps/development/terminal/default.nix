{ lib, config, ... }: {
  imports = [ ./yazi ./zsh ./tmux ];

  options = { terminal.enable = lib.mkEnableOption "Enable terminal module"; };
  config = lib.mkIf config.myHomeConfig.apps.development.terminal.enable {
    yazi.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault true;
  };
}
