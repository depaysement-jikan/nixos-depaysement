{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {elixir.enable = lib.mkEnableOption "Enable elixir module";};
  config = lib.mkIf config.homeManager.apps.development.languages.elixir.enable {
    home.packages = with pkgs; [elixir erlang elixir-ls];
  };
}
