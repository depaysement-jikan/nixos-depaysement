{
  lib,
  config,
  ...
}: {
  options = {starship.enable = lib.mkEnableOption "Enable starship module";};
  config = lib.mkIf config.homeManager.apps.development.terminal.starship.enable {
    programs.starship = let
      pure = builtins.fromTOML (builtins.readFile ./pure.toml);
    in {
      enable = true;
      settings = pure;
    };
  };
}
