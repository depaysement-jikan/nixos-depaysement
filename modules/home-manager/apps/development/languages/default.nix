{
  lib,
  config,
  ...
}: {
  imports = [
    ./go
    ./node
    ./markdown
    ./nix-lang
    ./sh
    ./c
    ./typescript
    ./lua
    ./python
    ./rust
    ./json
  ];

  options = {
    languages.enable = lib.mkEnableOption "Enable languages module";
  };
  config = lib.mkIf config.myHomeConfig.apps.development.languages.enable {
    go.enable = lib.mkDefault true;
    node.enable = lib.mkDefault true;
    markdown.enable = lib.mkDefault true;
    nix-lang.enable = lib.mkDefault true;
    sh.enable = lib.mkDefault true;
    c.enable = lib.mkDefault true;
    typescript.enable = lib.mkDefault true;
    lua.enable = lib.mkDefault true;
    python.enable = lib.mkDefault true;
    rust.enable = lib.mkDefault true;
  };
}
