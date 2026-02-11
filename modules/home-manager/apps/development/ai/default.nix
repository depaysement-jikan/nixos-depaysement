{
  lib,
  config,
  ...
}: {
  imports = [./crush];

  options = {ai.enable = lib.mkEnableOption "Enable ai module";};
  config = lib.mkIf config.myHomeConfig.apps.development.ai.enable {
    ai.enable = lib.mkDefault true;
  };
}
