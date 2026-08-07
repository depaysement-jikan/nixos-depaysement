{...}: {
  config = {
    nixos-generic = {
      desktop = {
        enable = true;
        sddm.enable = true;
        tuigreet.enable = false;
        hyprland.enable = true;
        homeManager.enable = true;
        audio.enable = true;
        openLinkHub.enable = false;
      };
    };
  };
}
