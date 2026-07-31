{pkgs, ...}: {
  imports = [
    ./security/sops.nix
  ];
  users.users.depaysement = {
    isNormalUser = true;
    extraGroups = ["wheel" "k3s" "sddm"];
    packages = with pkgs; [tree kitty];
    shell = pkgs.nu;
    hashedPassword = "$6$0.0l2IumZW8Hx98U$oI6ohUZ8/68s./AzWxd734C6oSbvNiAeYQgxIXH4FVkXOOdKfImRZxShH7DFAFj9ZAUFnSNf8KJP2XTzWNIRq1";
    homeMode = "711";
  };
  users.mutableUsers = false;
}
