{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {clipboard.enable = lib.mkEnableOption "Enable clipboard module";};
  config = lib.mkIf config.myHomeConfig.system.clipboard.enable {
    home.packages = with pkgs; [clipse];
  };
}
