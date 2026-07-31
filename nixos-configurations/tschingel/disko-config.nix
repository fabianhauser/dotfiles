{ config, ... }:
let
  physSizes = {
    # Note: GB, TB etc. are 10**x units in sgdisk
    # Whole disk is 1TB
    boot = "1GB";
    bootReserved = "1GB";
    luks = "997GB";
  };
  lvmSizes = {
    main = "900GB";
    swap = "32GB";
  };
  luksSettings = {
    allowDiscards = true;
    bypassWorkqueues = true;
  };

  disk = "/dev/disk/by-id/nvme-Micron_MTFDLBA1T0THJ-2BP15ABLT_260356100B9C";
in
{
  config.dotfiles.secureBoot.measured = {
    enable = true;
    device = config.disko.devices.disk.main.content.partitions.luks.device;
  };

  config.disko.devices = {
    disk.main = {
      type = "disk";
      device = disk;
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = physSizes.boot;
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "uid=0"
                "gid=0"
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };
          bootReserved.size = physSizes.bootReserved; # left empty by design
          luks = {
            size = physSizes.luks;
            content = {
              type = "luks";
              name = "crypted";
              # Supplied only at install time; also becomes the interactive-unlock passphrase.
              passwordFile = "/tmp/secret.key";
              settings = luksSettings;
              content = {
                type = "lvm_pv";
                vg = "vg_tschingel";
              };
            };
          };
        };
      };
    };
    lvm_vg.vg_tschingel = {
      type = "lvm_vg";
      lvs = {
        swap = {
          size = lvmSizes.swap;
          content = {
            type = "swap";
            resumeDevice = true;
          };
        };
        main = {
          size = lvmSizes.main;
          content = {
            type = "btrfs";
            mountOptions = [
              "defaults"
              "noatime"
            ];
            subvolumes = {
              "/nixos".mountpoint = "/";
              "/home".mountpoint = "/home";
            };
          };
        };
      };
    };
  };
}
