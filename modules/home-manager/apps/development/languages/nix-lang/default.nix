{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options = {nix-lang.enable = lib.mkEnableOption "Enable nix-lang module";};
  config = lib.mkIf config.myHomeConfig.apps.development.languages.nix-lang.enable {
    home.packages = with pkgs; [
      nixfmt-classic
      nixpkgs-fmt
      inputs.rnix-lsp.packages.x86_64-linux.rnix-lsp
      nixd
      alejandra
    ];
  };
}
