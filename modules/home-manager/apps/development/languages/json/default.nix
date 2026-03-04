{
  lib,
  pkgs,
  config,
  ...
}: {
  options = {json.enable = lib.mkEnableOption "Enable json module";};
  config = lib.mkIf config.homeManager.apps.development.languages.json.enable {
    home.packages = with pkgs; [
      vscode-json-languageserver
    ];
  };
}
