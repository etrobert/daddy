let
  hdd = serial: {
    type = "disk";
    device = "/dev/disk/by-id/ata-HGST_HUS726T4TALA6L1_${serial}";
    content = {
      type = "zfs";
      pool = "storage";
    };
  };
in
{
  disko.zfs.enable = true;
  disko.devices = {
    disk = {
      nvme = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WDC_CL_SN720_SDAQNTW-512G-2000_1851B2803575";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
      hdd1 = hdd "V6H4YB1S";
      hdd2 = hdd "V6H5N47S";
      hdd3 = hdd "V6H5GE3S";
      hdd4 = hdd "V6H5MKHS";
    };

    zpool.storage = {
      type = "zpool";
      mode = "raidz1";
      # The drives are 512-byte native; OVH's replacements may be 4K-sector.
      options.ashift = "12";
      # Otherwise `zfs mount -a` races systemd's fstab mount and fails the boot.
      rootFsOptions.mountpoint = "legacy";
      mountpoint = "/storage";

      datasets = {
        vm = {
          type = "zfs_fs";
          options = {
            mountpoint = "none";
            "com.sun:auto-snapshot" = "true";
            "com.sun:auto-snapshot:daily" = "true";
          };
        };
        "vm/softer" = {
          type = "zfs_fs";
          mountpoint = "/storage/vm_softer";
          options = {
            # Otherwise `zfs create` and `zfs mount -a` mount it before /storage, which then hides it.
            mountpoint = "legacy";
            compression = "zstd";
            quota = "3T";
            reservation = "3T";
          };
        };
      };
    };
  };
}
