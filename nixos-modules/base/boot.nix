{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  environment.systemPackages = [
    pkgs.sbctl
  ];

  boot = {
    loader.timeout = 2;
    tmp.useTmpfs = true;
    kernelPackages = pkgs.linuxPackages_latest;
    bootspec.enable = true;

    loader.efi.canTouchEfiVariables = true;
    initrd.systemd.enable = true;

    # Lanzaboote currently replaces the systemd-boot module.
    # This setting is usually set to true in configuration.nix
    # generated at installation time. So we force it to false
    # for now.
    loader.systemd-boot.enable = lib.mkForce false;

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };
}
