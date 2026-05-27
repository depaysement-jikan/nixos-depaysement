{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {elixir.enable = lib.mkEnableOption "Enable elixir module";};
  config = lib.mkIf config.homeManager.apps.development.languages.elixir.enable {
    home.packages = with pkgs; [
      elixir
      erlang
      elixir-ls
      beamPackages.hex
      beamPackages.rebar3
      inotify-tools
    ];
    home.activation.installPhoenix = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if ! ${pkgs.elixir}/bin/mix archive | grep -q phx_new; then
        ${pkgs.elixir}/bin/mix archive.install hex phx_new --force
      fi
    '';
  };
}
