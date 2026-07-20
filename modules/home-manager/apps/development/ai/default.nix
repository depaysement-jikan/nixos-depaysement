{
  lib,
  config,
  ...
}: {
  imports = [./crush ./claude];

  options = {ai.enable = lib.mkEnableOption "Enable ai module";};
  config = lib.mkIf config.homeManager.apps.development.ai.enable {
    ai.enable = lib.mkDefault true;
  };
}
