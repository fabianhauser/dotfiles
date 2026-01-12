{
  pkgs,
  lib,
  config,
  ...
}:
{

  dconf.settings = {
    "apps/gnome-keyring/daemon-components".ssh = false;
  };
  #TODO: ENV variabls for agent
  programs.gpg = {
    enable = true;
    package = pkgs.gnupg;
    settings = {
      "use-agent" = true;
      "trust-model" = "tofu";
      "no-emit-version" = true;
      "no-comments" = true;
      "sig-notation" = "issuer-fpr@notations.openpgp.fifthhorseman.net=%g";
      "keyserver" = "hkps://keys.openpgp.org";
      "keyserver-options" = "auto-key-retrieve no-honor-keyserver-url";
      "personal-cipher-preferences" = "AES256 AES192 AES CAST5";
      "cert-digest-algo" = "SHA512";
      "personal-digest-preferences" = "SHA512 SHA384 SHA256 SHA224";
      "default-preference-list" =
        "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed";
      "display-charset" = "utf-8";
      "fixed-list-mode" = true;
      "with-fingerprint" = true;
      "keyid-format" = "0xlong";
      "verify-options" = "show-uid-validity";
      "list-options" = "show-uid-validity";
    };
    scdaemonSettings = {
      disable-ccid = true;
    };
    # TODO: Complete this list and maybe transfer to managed configuration?
    #publicKeys = [
    # { source = "./fabian.hauser@qo.is.pub"; trust = 5; }
    #];
  };
  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
    enableSshSupport = true;
    enableExtraSocket = true;
    pinentry.package =
      if config.targets.genericLinux.enable then pkgs.pinentry-gnome3 else pkgs.pinentry-bemenu;
    sshKeys = [
      "638143D3F6421377E9D4C7F1D2EDC5AA0A860351" # 0x3E957C9C8CB5D6B2 / fabian.hauser@qo.is
    ];
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
}
