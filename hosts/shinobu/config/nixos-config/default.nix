{...}: {
  config = {
    nixos-generic = {
      desktop = {
        enable = true;
        sddm.enable = false;
        tuigreet.enable = true;
        hyprland.enable = true;
        homeManager.enable = true;
        audio.enable = true;
        openLinkHub.enable = false;
      };
    };
  };
}
