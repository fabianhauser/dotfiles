{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.desktop.security;
in
{
  config = lib.mkIf cfg.enable {
    programs.gpg.scdaemonSettings = {
      disable-ccid = true;
    };

    services.gpg-agent = {
      enableScDaemon = true;
      enableSshSupport = true;
      enableExtraSocket = true;
      pinentry.package =
        if config.targets.genericLinux.enable then pkgs.pinentry-gnome3 else pkgs.pinentry-bemenu;
      sshKeys = [
        "638143D3F6421377E9D4C7F1D2EDC5AA0A860351" # 0x3E957C9C8CB5D6B2 / fabian.hauser@qo.is
      ];
    };

    dconf.settings = {
      "apps/gnome-keyring/daemon-components".ssh = false;
    };

    systemd.user.sockets.yubikey-touch-detector = {
      Unit.Description = "Unix socket activation for YubiKey touch detector service";
      Socket = {
        ListenStream = "%t/yubikey-touch-detector.socket";
        RemoveOnStop = true;
      };
      Install.WantedBy = [ "sockets.target" ];
    };

    systemd.user.services.yubikey-touch-detector = {
      Unit = {
        Description = "Detects when your YubiKey is waiting for a touch";
        Requires = "yubikey-touch-detector.socket";
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.yubikey-touch-detector} --libnotify";
        EnvironmentFile = "-%E/yubikey-touch-detector/service.conf";
      };
      Install = {
        Also = "yubikey-touch-detector.socket";
        WantedBy = [ "default.target" ];
      };
    };
  };
}
