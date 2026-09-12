# Thin add-ons on top of the upstream nixpkgs k3s module
# (nixos/modules/services/cluster/rancher). This used to be a ~1000 line fork of
# an older revision of that module; everything it provided -- `manifests`,
# `charts`, `autoDeployCharts`, `images`, `containerdConfigTemplate`,
# `extraKubeletConfig`, `extraKubeProxyConfig`, `gracefulNodeShutdown` -- now
# lives upstream with identical option shapes, so the fork was dropped.
#
# Only two things are still ours: the `manifestDir` path (upstream keeps it as
# an internal binding, but other modules here need to reference it) and the
# stale-symlink cleanup below.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.k3s;
in {
  imports = [./secrets.nix];

  options.services.k3s.manifestDir = lib.mkOption {
    type = lib.types.path;
    default = "/var/lib/rancher/k3s/server/manifests";
    readOnly = true;
    description = ''
      Directory k3s reads auto-deploying manifests from. This mirrors the path
      the upstream module derives internally and exists so other modules can
      reference it instead of hardcoding the string. It is read-only because
      changing it here would not change where upstream writes.
    '';
  };

  config = lib.mkIf cfg.enable {
    # systemd-tmpfiles `L+` creates the symlinks the k3s module declares, but it
    # never removes ones that have since been dropped from the configuration.
    # Without this, deleting a manifest from Nix leaves the symlink behind and
    # k3s keeps applying it forever.
    #
    # Only symlinks are considered: k3s writes its own packaged component
    # manifests (coredns, local-storage, traefik, ...) into this directory as
    # regular files, and those must not be touched.
    systemd.services.k3s-manifest-cleanup = {
      description = "Remove k3s manifest symlinks no longer declared in the configuration";
      after = ["systemd-tmpfiles-resetup.service"];
      wantedBy = ["multi-user.target"];
      before = ["k3s.service"];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "k3s-manifest-cleanup" ''
          set -euo pipefail
          dir=${lib.escapeShellArg cfg.manifestDir}
          conf=/etc/tmpfiles.d/10-k3s.conf

          [ -d "$dir" ] || exit 0
          [ -r "$conf" ] || exit 0

          for f in "$dir"/*.yaml; do
            [ -L "$f" ] || continue
            # tmpfiles.d quotes the target path: 'L+' '/path/to/file.yaml' '-' ...
            if ! ${pkgs.gnugrep}/bin/grep -qF -- "'$f'" "$conf"; then
              echo "Removing stale manifest symlink: $f"
              rm -f "$f"
            fi
          done
        '';
      };
    };
  };
}
