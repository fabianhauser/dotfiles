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

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
}
