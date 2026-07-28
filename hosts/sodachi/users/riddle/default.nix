{
  pkgs,
  ...
}: {
  imports = [
    ./security/sops.nix
  ];
  users.users.riddle = {
    isNormalUser = true;
    extraGroups = ["wheel" "k3s" "sddm"];
    packages = with pkgs; [tree kitty];
    shell = pkgs.zsh;
    password = "12345";
    homeMode = "711";
  };
  users.mutableUsers = false;
}
