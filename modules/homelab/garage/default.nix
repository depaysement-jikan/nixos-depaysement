{lib, ...}: let
  inherit (lib) types;
in {
  options.homelab.garage = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
    };
    ingressHost = lib.mkOption {
      type = types.nullOr types.str;
      default = "";
      description = "Hostname base for garage ingress (defaults to garage.i.<domain> if gated, garage.<domain> otherwise)";
    };
  };
}
