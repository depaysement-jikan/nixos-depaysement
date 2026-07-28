_: {
  imports = [./utils/options.nix];

  hosts = {
    tsukinara = {
      system = "x86_64-linux";
      profile = "desktop";
      platform = "nixos";
      users = {
        depaysement = {
          root.enable = true;
          shell = "zsh";
        };
      };
    };
    shinobu = {
      system = "x86_64-linux";
      profile = "desktop";
      platform = "nixos";
      users = {
        kokoro = {
          root.enable = true;
          shell = "nu";
        };
      };
    };
    yotsugi = {
      system = "x86_64-linux";
      profile = "desktop";
      platform = "nixos";
      users = {
        yay = {
          root.enable = true;
          shell = "zsh";
        };
      };
    };
    sodachi = {
      system = "x86_64-linux";
      profile = "desktop";
      platform = "nixos";
      users = {
        riddle = {
          root.enable = true;
          shell = "zsh";
        };
      };
    };
  };
}
