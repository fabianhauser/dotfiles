{
  pkgs,
  ...
}:

{
  imports = [
    ./applications.nix
    ./boot.nix
    ./unfree.nix
    ./users.nix
  ];

  console.keyMap = "de_CH-latin1";
  i18n.defaultLocale = "en_US.UTF-8";

  # Package management
  nix = {
    settings.trusted-users = [
      "root"
      "@wheel"
    ];
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 60d";
    };
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

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

  services.dbus.implementation = "broker";
}
