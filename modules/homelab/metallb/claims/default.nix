# Central registry of every LoadBalancer IP the homelab hands out.
#
# Each service module registers what it asks MetalLB for; this module then
# fails the build on a double-booked address instead of letting the loser sit
# at <pending> forever. Two services may legitimately share one IP, but only
# when both carry the same metallb.universe.tf/allow-shared-ip value, so a
# shared claim must declare a matching shareKey.
{
  lib,
  config,
  ...
}: let
  cfg = config.homelab.metallb;

  parseIp = ip: let
    m = builtins.match "([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})\\.([0-9]{1,3})" ip;
  in
    if m == null
    then null
    else let
      octets = map lib.toInt m;
    in
      if lib.any (o: o > 255) octets
      then null
      else lib.foldl' (acc: o: acc * 256 + o) 0 octets;

  # Only plain "start-end" pool entries are range-checked; CIDR entries are
  # skipped rather than guessed at.
  parseRange = entry: let
    m = builtins.match "([0-9.]+)-([0-9.]+)" entry;
    start =
      if m == null
      then null
      else parseIp (builtins.elemAt m 0);
    end =
      if m == null
      then null
      else parseIp (builtins.elemAt m 1);
  in
    if start == null || end == null
    then null
    else {inherit start end;};

  ranges = lib.filter (r: r != null) (map parseRange cfg.addresses);

  byIp = lib.groupBy (c: c.ip) cfg.claims;

  shareable = claims: let
    key = (builtins.head claims).shareKey;
  in
    key != null && lib.all (c: c.shareKey == key) claims;

  conflicts =
    lib.filterAttrs
    (_: claims: builtins.length claims > 1 && !(shareable claims))
    byIp;

  owners = claims: lib.concatMapStringsSep ", " (c: c.owner) claims;

  inPool = ip: let
    i = parseIp ip;
  in
    i == null || lib.any (r: i >= r.start && i <= r.end) ranges;
in {
  options.homelab.metallb.claims = lib.mkOption {
    default = [];
    description = ''
      LoadBalancer IPs requested by homelab services. Service modules append to
      this so that duplicate allocations are caught at build time.
    '';
    type = lib.types.listOf (lib.types.submodule {
      options = {
        owner = lib.mkOption {
          type = lib.types.str;
          description = "Service that requests this address, for error messages.";
        };
        ip = lib.mkOption {
          type = lib.types.str;
          description = "The requested LoadBalancer IP.";
        };
        shareKey = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            Value of the metallb.universe.tf/allow-shared-ip annotation on the
            Service. Claims on the same IP are only permitted when every one of
            them sets the same non-null shareKey.
          '';
        };
      };
    });
  };

  config = lib.mkIf (cfg.enable && config.homelab.enable) {
    assertions =
      [
        {
          assertion = conflicts == {};
          message = ''
            homelab.metallb: the same LoadBalancer IP is claimed by services that cannot share it.
            MetalLB will assign each address once and leave the other Services at <pending>.
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (ip: claims: "  ${ip} <- ${owners claims}") conflicts)}
            Give each service its own address, or annotate them with a matching allow-shared-ip key.
          '';
        }
      ]
      ++ map (c: {
        assertion = parseIp c.ip != null;
        message = "homelab.metallb: ${c.owner} requests ${c.ip}, which is not a valid IPv4 address.";
      })
      cfg.claims
      ++ lib.optionals (ranges != []) (map (c: {
          assertion = inPool c.ip;
          message = ''
            homelab.metallb: ${c.owner} requests ${c.ip}, which falls outside the configured pool
            (${lib.concatStringsSep ", " cfg.addresses}). MetalLB will leave that Service at <pending>.
          '';
        })
        cfg.claims);
  };
}
