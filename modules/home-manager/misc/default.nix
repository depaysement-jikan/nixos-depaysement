{
  lib,
  config,
  ...
}: let
  cfg = config.homeManager.misc;
in {
  imports = [./cli];

  options.homeManager.misc = {
    enable = lib.mkEnableOption "misc programs";
    cli.enable = lib.mkEnableOption "misc cli programs";
  };

  config = lib.mkIf cfg.enable {
    cli.enable = lib.mkDefault cfg.cli.enable;
  };
}
