{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {node.enable = lib.mkEnableOption "Enable node module";};
  config = lib.mkIf config.myHomeConfig.apps.development.languages.node.enable {
    home.packages = with pkgs; [nodejs_20 pnpm yarn deno];
  };
}
