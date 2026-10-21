{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {rust.enable = lib.mkEnableOption "Enable rust module";};
  config = lib.mkIf config.homeManager.apps.development.languages.rust.enable {
    home.packages = with pkgs; [
      rustfmt
      rustc
      llvmPackages.lld
      cargo
      rust-analyzer
      openssl.dev
      cargo-watch
      bacon
      clippy
      cargo-edit
      pkg-config
      dioxus-cli
    ];
  };
}
