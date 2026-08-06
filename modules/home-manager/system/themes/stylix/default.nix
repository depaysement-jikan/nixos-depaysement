{inputs, ...}: let
in {imports = [./stylix.nix inputs.stylix.homeModules.stylix];}
