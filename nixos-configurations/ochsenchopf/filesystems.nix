{
  lib,
  ...
}:
{

  boot.initrd.luks.devices = {
    "luks".device = "/dev/disk/by-label/luks";
  };

  fileSystems =
    let
      rootdev = "/dev/disk/by-label/hv_ochsenchopf";
    in
    {
      "/" = {
        device = rootdev;
        fsType = "btrfs";
        options = [ "subvol=nixos" ];
      };
      "/home" = {
        device = rootdev;
        fsType = "btrfs";
        options = [ "subvol=home" ];
      };
      "/boot" = {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
      };
    };

  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  boot.lanzaboote.pkiBundle = lib.mkForce "/etc/secureboot"; # TODO: Migrate to /var/lib/sbctl, see default config.
}
