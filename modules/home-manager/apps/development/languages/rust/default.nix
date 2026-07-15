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
      cargo-edit
      pkg-config
      (pkgs.rustPlatform.buildRustPackage {
        pname = "dioxus-cli";
        version = "0.7.6";
        src = pkgs.fetchCrate {
          pname = "dioxus-cli";
          version = "0.7.6";
          sha256 = "sha256-PKidohK85wv/ZN9WcNS+HTlVGgR5o07gWLshZhzyg5k=";
        };
        nativeBuildInputs = [
          pkgs.pkg-config
        ];
        buildInputs = [
          pkgs.openssl.dev
        ];
        OPENSSL_NO_VENDOR = 1;
        doCheck = false;
        cargoHash = "sha256-T6xLlu8XeJPm+ULgpTALTT93X55ExJhDMuhpal2QLhg=";
      })
    ];
  };
}
