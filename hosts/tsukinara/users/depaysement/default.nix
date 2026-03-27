{
  pkgs,
  config,
  ...
}: {
  users.users.depaysement = {
    isNormalUser = true;
    extraGroups = ["wheel" "k3s" "sddm"];
    packages = with pkgs; [tree kitty];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets.depaysementUserPassword.path;
    homeMode = "711";
  };
}
