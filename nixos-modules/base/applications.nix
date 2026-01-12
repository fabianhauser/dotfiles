{
  pkgs,
  ...
}:

{

  environment.etc = {
    gitconfig.source = ./etc/gitconfig;
    vimrc.source = ./etc/vimrc;
  };

  programs.autojump.enable = true;
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

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
      pwgen
      powertop
      lm_sensors
    ]
    ++ [
      nix-index
      nix-diff
    ]
    ++ [
      powerline-go
    ]
    ++ [
      # File Utilities
      ripgrep
      unzip
      p7zip
      iotop
      tree
      git
      git-lfs
    ]
    ++ [
      # Networking Utilities
      nmap
      bind
      curl
      wget
      wol
      rsync
      sshuttle
      iftop
      mailutils
      bluez-tools
    ];
}
