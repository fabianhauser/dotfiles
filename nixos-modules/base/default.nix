{
  pkgs,
  ...
}:

{
  imports = [
    ./applications.nix
    ./boot.nix
    ./overlays.nix
    ./secure-boot-measured.nix
    ./unfree.nix
    ./users.nix
  ];

  console.useXkbConfig = true;
  i18n.defaultLocale = "en_US.UTF-8";

  # Package management
  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];

      # Read by nixos-anywhere to configure the installer environment.
      # cache.nixos.org is appended by nixpkgs itself.
      substituters = [ "https://attic.qo.is/dotfiles" ];
      trusted-public-keys = [ "dotfiles:KpLi0qe5O5rb8E8N8vntZWBDqFwG3Ksx4AFGizYCLoU=" ];
    };
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

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.dbus.implementation = "broker";
}
