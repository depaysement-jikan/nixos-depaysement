{
  inputs,
  lib,
  config,
  settings,
  ...
}: {
  options = {noctalia.enable = lib.mkEnableOption "Enable noctalia";};
  imports = [
    inputs.noctalia.homeModules.default
  ];
  config = lib.mkIf config.homeManager.desktop.noctalia.enable {
    programs.noctalia-shell = {
      enable = true;
      settings = {
        bar = {
          density = "compact";
          position = "bottom";
          showCapsule = false;
          widgets = {
            left = [
              {
                id = "ControlCenter";
                useDistroLogo = true;
              }
              {
                id = "Network";
              }
              {
                id = "Bluetooth";
              }
            ];
            center = [
              {
                hideUnoccupied = false;
                id = "Workspace";
                labelMode = "none";
              }
            ];
            right = [
              {
                alwaysShowPercentage = false;
                id = "Battery";
                warningThreshold = 30;
              }
              {
                formatHorizontal = "HH:mm";
                formatVertical = "HH mm";
                id = "Clock";
                useMonospacedFont = true;
                usePrimaryColor = true;
              }
            ];
          };
        };
        colorSchemes.predefinedScheme = "Monochrome";
        general = {
          avatarImage = "/home/${settings.user}/.face";
          radiusRatio = 0.2;
        };
        location = {
          monthBeforeDay = true;
          name = "Marseille, France";
        };
      };
    };
  };
}
