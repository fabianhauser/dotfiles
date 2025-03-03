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
      comma
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
