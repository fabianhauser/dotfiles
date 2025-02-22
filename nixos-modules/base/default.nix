{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  users = {
    fhauser = {
      uid = 1000;
      isNormalUser = true;
      description = "Fabian Hauser";
      group = "fhauser";
      extraGroups = [
        "wheel"
        "video"
        "docker"
        "networkmanager"
        "libvirtd"
        "adbusers"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIPF8ZV7vhpbVvLxiKq8ANVusNUHMbtii5MuvjxCbVz7vSNVPo9OOLvYyDqhbRAWMTdQeGZVAaALBufKKmprDTRFMpnA7Ut4TFrdz/5DTaR2KEjJ7P75moH+0xooR/GsbzFGsNBSQSXK3u1igndPYEC/PqCHN++32kDo2wLqTB4VLrEovU3iq8BMckn329Bu1fGbXKTgDpEvUEEwFO2brQZLMmzILGF/v4B9ImEGtinAUNgDSfEpgPN23sdWQH9rwEClGv95JmWNf05tuVomhZzOBtCFoAno3XB1nj16avjsqJ3aGFY2CCcfsNrwKzhIotmm82bcI4BJuJIVRIKbZ1 cardno:000603507108"
      ];
    };
  };
in
{
  imports = [
    inputs.private.nixosModules.users # Contains hashedPasswords for users.
    ./unfree.nix
    ./applications.nix
  ];

  boot.loader.timeout = 2;
  boot.tmp.useTmpfs = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.bootspec.enable = true;

  catppuccin = {
    flavor = "mocha";
    tty.enable = true;
  };

  console.keyMap = "de_CH-latin1";
  i18n.defaultLocale = "en_US.UTF-8";

  users.mutableUsers = false;
  users.groups = {
    fhauser.gid = 1000;
  };
  users.users = users // {
    root.openssh.authorizedKeys.keys =
      with lib;
      concatLists (
        mapAttrsToList (
          _name: user: if elem "wheel" user.extraGroups then user.openssh.authorizedKeys.keys else [ ]
        ) users
      );
  };

  # Package management
  nix = {
    settings.trusted-users = [
      "root"
      "@wheel"
    ];
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 60d";
    };
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # System Services
  services.btrfs.autoScrub.enable = true;
  services.fwupd.enable = true;

  # Network services
  networking.networkmanager.enable = true;
  networking.firewall = {
    allowPing = true;
    allowedTCPPorts = [ 22 ];
  };
  systemd.services.NetworkManager-wait-online.enable = false;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Default Settings
  environment.etc = {
    gitconfig.source = ./etc/gitconfig;
    vimrc.source = ./etc/vimrc;
  };

  programs.autojump.enable = true;
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };
  environment.systemPackages = [ pkgs.comma ];

  services.dbus.implementation = "broker";
}
