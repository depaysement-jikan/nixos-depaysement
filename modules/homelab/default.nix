{...}: {
  services.k3s = {
    enable = true;
    extraFlags = [
      "--write-kubeconfig-group k3s"
      "--write-kubeconfig-mode 0660"
    ];
  };
  users.groups.k3s = {};
}
