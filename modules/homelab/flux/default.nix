{lib, ...}: {
  imports = [./bucket];
  options.homelab.flux = {
    endpoint = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    webhook = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    accessKeyId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    secretAccessKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    bucketName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };
}
