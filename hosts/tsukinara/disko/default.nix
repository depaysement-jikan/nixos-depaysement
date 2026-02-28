# /etc/nixos/disko-configuration.nix
{
  disko = {
    devices = {
      disk.main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                device = "/dev/disk/by-uuid/4D6F-33A5";
              };
            };
            esp = {
              name = "ESP";
              size = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                device = "/dev/disk/by-uuid/4D6F-33A5";
              };
            };
            swap = {
              name = "swap";
              size = "4G";
              content = {
                type = "swap";
                device = "/dev/disk/by-uuid/b78dabd8-69ed-48e1-8356-3efb0cf8dc7c";
                resumeDevice = true;
              };
            };
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                device = "/dev/disk/by-uuid/2315fd0e-1171-4960-a8da-ad651e0c3f9c";
              };
            };
          };
        };
      };
    };
  };
}
