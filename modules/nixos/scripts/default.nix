{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf config.nixos-generic.desktop.sddm.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "mkHost" (builtins.readFile ./mkHost.sh))
      (pkgs.writeShellScriptBin "mkUser" (builtins.readFile ./mkUser.sh))
      (pkgs.writeShellScriptBin "resetSopsSecrets" (builtins.readFile ./resetSopsSecrets.sh))
      (pkgs.writeShellScriptBin "shared/generateUserConfigFunctions.sh" (builtins.readFile ./shared/generateUserConfigFunctions.sh))
      (pkgs.writeShellScriptBin "shared/generateHostConfigFunctions.sh" (builtins.readFile ./shared/generateHostConfigFunctions.sh))
      (pkgs.writeShellScriptBin "shared/resetSopsSecretsFunctions.sh" (builtins.readFile ./shared/resetSopsSecretsFunctions.sh))
    ];
  };
}
