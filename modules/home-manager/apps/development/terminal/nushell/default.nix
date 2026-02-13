{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {nushell.enable = lib.mkEnableOption "Enable nushell module";};
  config = lib.mkIf config.myHomeConfig.apps.development.terminal.nushell.enable {
    home = {
      packages = with pkgs; [
        nufmt
        inshellisense
        nushell
      ];
    };
  };
}
