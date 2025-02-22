{
  pkgs,
  ...
}:

{
  environment.systemPackages =
    with pkgs;
    [
      tmux
      pciutils
      dmidecode
      smartmontools
      borgbackup
      iw
      killall
      bc
      efibootmgr
      efitools
      efivar
      mkpasswd
      rename
      wipe
      gnupg
      pass-wayland
      pwgen
      powertop
      lm_sensors
    ]
    ++ [
      nixfmt-rfc-style
      nix-index
      nix-diff
      nixpkgs-review
      nixos-option
    ]
    ++ [
      autojump
      powerline-go
    ]
    ++ [
      # File Utilities
      ripgrep
      unzip
      p7zip
      unrar
      iotop
      cabextract
      tree
      vim
      vimPlugins.pathogen
      vimPlugins.airline
      git
      git-lfs
    ]
    ++ [
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
    ]
    ++ [
      # Networking Utilities
      nmap
      bind
      curl
      wget
      tor
      whois
      wol
      rsync
      sshuttle
      iftop
      mailutils
      imapsync
      bluez-tools
    ];
}
