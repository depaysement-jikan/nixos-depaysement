{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  sddm-theme = inputs.silentSDDM.packages.${pkgs.system}.default;
in {
  options.nixos-generic.desktop.sddm = {
    enable = lib.mkEnableOption "SDDM Display Manager";
  };

  config = lib.mkIf config.nixos-generic.desktop.sddm.enable {
    environment.systemPackages = [
      sddm-theme
    ];

    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      enableHidpi = true;
      theme = sddm-theme.pname;
      package = pkgs.kdePackages.sddm;
      extraPackages = sddm-theme.propagatedBuildInputs;

      settings = {
        Wayland = {EnableHiDPI = true;};
        General = {
          GreeterEnvironment = "QML2_IMPORT_PATH=${sddm-theme}/share/sddm/themes/${sddm-theme.pname}/components/,QT_IM_MODULE=qtvirtualkeyboard";
          InputMethod = "qtvirtualkeyboard";
        };
      };
    };
  };
}
