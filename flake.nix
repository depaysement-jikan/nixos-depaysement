{
  description = "Depaysement's Flake";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    catppuccin.url = "github:catppuccin/nix/release-25.05";
    rnix-lsp.url = "github:nix-community/rnix-lsp";
    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    hostEval = nixpkgs.lib.evalModules {
      modules = [
        {_module.args = {inherit inputs;};}
        ./nixos/configuration.nix
        ./nixos/utils/options.nix
      ];
    };

    mkHost = hostName: attrs: let
      nixosSystem = nixpkgs.lib.nixosSystem;
    in
      nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          systemUsers = attrs.users;
          inherit (config.hosts.${hostName}) system profile platform;
          meta = {hostname = hostName;};
        };
        modules = [
          ./modules/nixos
          ./hosts/${hostName}
          {networking = {inherit hostName;};}
        ];
      };

    mkHome = hostName: username: let
      pkgs = import nixpkgs {inherit (config.hosts.${hostName}) system;};
      shell = "${config.hosts.${hostName}.users.${username}.shell}";
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs outputs shell;
          settings = {user = username;};
          meta = {hostname = hostName;};
        };
        modules = [
          ./modules/home-manager
          ./modules/nixos
        ];
      };

    inherit (hostEval) config;
    inherit (nixpkgs) lib;

    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    # # Home Manager CLI per system
    # home-manager =
    #   forAllSystems (system: home-manager.packages.${system}.home-manager);

    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages =
      forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter =
      forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations =
      config.hosts
      |> lib.filterAttrs (_: attrs: attrs.platform == "nixos")
      |> lib.mapAttrs (hostName: attrs: mkHost hostName attrs);

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations =
      config.hosts
      |> lib.filterAttrs (_: attrs: attrs.platform != "mobile" && attrs.users != null)
      |> builtins.attrNames
      |> map (
        host:
          config.hosts.${host}.users
          |> builtins.attrNames
          |> map (user: {
            name = "${user}@${host}";
            value = mkHome host user;
          })
      )
      |> builtins.concatLists
      |> builtins.listToAttrs;
  };
}
