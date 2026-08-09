{
  lib,
  config,
  ...
}: {
  options.foot.enable = lib.mkEnableOption "Enable foot module";

  config = lib.mkIf config.homeManager.apps.development.terminal.foot.enable {
    programs.foot = {
      enable = true;

      settings = {
        main = {};
      };
    };
  };
}
