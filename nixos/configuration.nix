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
  };
}
