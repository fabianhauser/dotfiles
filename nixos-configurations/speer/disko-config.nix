{ ... }:
{
  disko.devices = {
    disk = rec {
      system-1 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S4J4NX0W821176E";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1G";
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
            raid_system = {
              start = "30G";
              size = "100%";
              content = {
                type = "mdraid";
                name = "raid_system";
              };
            };
          };
        };
      };
      #system-2 = {
      #  type = "disk";
      #  device = "/dev/disk/by-id/nvme-XXXXX";
      #  content = pkgs.lib.recursiveUpdate system-1.content {
      #    partitions.boot.content.mountpoint = "/boot-secondary";
      #  };
      #};
    };

    mdadm = {
      "raid_system" = {
        type = "mdadm";
        level = 1;
        content = {
          type = "luks";
          name = "crypted_system";
          passwordFile = "/run/secrets/system/hdd.key";
          settings = {
            allowDiscards = true;
            bypassWorkqueues = true;
          };
          content = {
            type = "lvm_pv";
            vg = "vg_system";
          };
        };
      };
    };
    lvm_vg = {
      vg_system = {
        type = "lvm_vg";
        lvs = {
          swap = {
            size = "32G";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };
          data = {
            size = "1000GB";
            content = {
              type = "btrfs";
              mountOptions = [
                "defaults"
                "noatime"
              ];
              subvolumes."/home".mountpoint = "/home";
            };
          };
          hv_speer = {
            size = "200GiB";
            content = {
              type = "btrfs";
              mountOptions = [
                "defaults"
                "noatime"
              ];
              subvolumes = {
                "/root".mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
