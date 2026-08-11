_: {
  hosts = {
    tsukinara = {
      system = "x86_64-linux";
      profile = "desktop";
      platform = "nixos";
      users = {
        depaysement = {
          root.enable = true;
          shell = "nushell";
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
          shell = "nushell";
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
