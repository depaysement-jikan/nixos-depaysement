{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {claude.enable = lib.mkEnableOption "Enable claude module";};
  config = lib.mkIf config.homeManager.apps.development.ai.claude.enable {
    home.packages = with pkgs; [claude-code];
  };
}
