{lib, ...}: {
  imports = [./cloudnative-pg];
  options.homelab.databases = {
    enable = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = true;
    };
    cloudnative-pg = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
    };
  };
}
