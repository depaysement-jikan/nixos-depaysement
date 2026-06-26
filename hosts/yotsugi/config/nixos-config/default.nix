{...}: {
  config = {
    nixos-generic = {
      desktop = {
        enable = true;
        sddm.enable = true;
        hyprland.enable = true;
        homeManager.enable = true;
      };
    };
  };
}
