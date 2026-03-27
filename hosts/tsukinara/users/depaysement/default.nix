{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./security/sops.nix
  ];
  users.users.depaysement = {
    isNormalUser = true;
    extraGroups = ["wheel" "k3s" "sddm"];
    packages = with pkgs; [tree kitty];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.userHashedPassword.path;
    homeMode = "711";
  };
}
