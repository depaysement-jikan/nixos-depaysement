{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./security/sops.nix
  ];
  users.users.kokoro = {
    isNormalUser = true;
    extraGroups = ["wheel" "k3s" "sddm"];
    packages = with pkgs; [tree kitty];
    shell = pkgs.nushell;
    hashedPasswordFile = config.sops.secrets.userHashedPassword.path;
    homeMode = "711";
  };
  users.mutableUsers = false;
}
