{ inputs, pkgs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  services.btrfs.autoScrub.enable = true;

  environment.systemPackages = with pkgs; [
    # Filesystem & Disk Utilities
    exfat
    samba
    cifs-utils
    keyutils # required for cifs kerberos auth
    sshfs-fuse
    hdparm
    mtpfs
    ntfs3g
    smartmontools
    parted
    usbutils
  ];
}
