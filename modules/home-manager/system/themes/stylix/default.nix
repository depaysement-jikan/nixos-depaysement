{
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.myHomeConfig.system.themes.stylix;
in {imports = [./stylix.nix inputs.stylix.homeModules.stylix];}
