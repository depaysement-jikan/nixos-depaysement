{
  description = "Depaysement's Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
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
    disko.url = "github:nix-community/disko";
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
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
          ./hosts/${hostName}/config/homelab-config
          ./hosts/${hostName}/config/nixos-config
          disko.nixosModules.disko
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
          ./hosts/${hostName}/config/home-manager-config
        ];
      };

    inherit (hostEval) config;
    inherit (nixpkgs) lib;

    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages =
      forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    formatter =
      forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    overlays = import ./overlays {inherit inputs;};
    nixosModules = {
      default = import ./modules/nixos;
    };
    homeManagerModules = import ./modules/home-manager;

    nixosConfigurations =
      config.hosts
      |> lib.filterAttrs (_: attrs: attrs.platform == "nixos")
      |> lib.mapAttrs (hostName: attrs: mkHost hostName attrs);

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
