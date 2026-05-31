{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./gpg.nix
    ./shell.nix
    ./ssh.nix
    ./vim.nix
  ];

  home.packages = with pkgs; [
    # General utilities
    tmux
    bc
    mkpasswd
    rename
    wipe
    pass-wayland
    pwgen
    powertop

    # File utilities
    ripgrep
    unzip
    p7zip
    iotop
    tree

    # Networking utilities
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
