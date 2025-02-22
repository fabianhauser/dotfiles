{
  pkgs,
  lib,
  ...
}:
let
  mkDefault = lib.mkDefault;
in
{

  environment.systemPackages = with pkgs; [
    freetype
    lxappearance
    sound-theme-freedesktop

    qt5.qtwayland # Required for qt applications
  ];
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.sessionVariables.DO_NOT_TRACK = "1";

  programs = {
    gnome-terminal.enable = false;
    evolution = {
      enable = true;
      #plugins = [ pkgs.evolution-ews ];
    };
    geary.enable = false;
    light.enable = true;

    dconf.enable = true;

    sway.enable = true;
  };

  services.gnome = {
    # TODO: Do this manually and not all at once.
    core-utilities.enable = true;
    core-os-services.enable = false;

    gnome-keyring.enable = true;
    evolution-data-server.enable = true;
    gnome-online-accounts.enable = true;
    gnome-remote-desktop.enable = true;
    sushi.enable = false;
  };

  ##########
  # gnome.core-os-services excerpt

  security.polkit.enable = true;
  services.power-profiles-daemon.enable = false; # TODO: Remove

  # Explicitly enabled since GNOME will be severely broken without these.
  xdg.mime.enable = true;
  xdg.icons.enable = true;

  # Harmonize Qt5 application style and also make them use the portal for file chooser dialog.
  qt = {
    enable = mkDefault true;
    platformTheme = mkDefault "gnome";
    style = mkDefault "adwaita";
  };

  # Needed for themes and backgrounds
  environment.pathsToLink = [
    "/share" # TODO: https://github.com/NixOS/nixpkgs/issues/47173
  ];

  # GVFS
  services.gvfs.enable = true;

  # Flatpak
  services.flatpak.enable = true;

  # Portals
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
