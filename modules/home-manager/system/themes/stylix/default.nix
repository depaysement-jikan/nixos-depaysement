{
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.homeManager.system.themes.stylix;
in {imports = [./stylix.nix inputs.stylix.homeModules.stylix];}
