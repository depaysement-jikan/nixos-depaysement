{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.nixos-generic.desktop.sddm.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "mkHost" (builtins.readFile ./mkHost.sh))
    ];
  };
}
