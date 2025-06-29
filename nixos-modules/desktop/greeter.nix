{
  ...
}:
{

  services.xserver.windowManager.i3.enable = false;

  services.displayManager = {
    defaultSession = "sway";
    gdm = {
      enable = true;
      wayland = true;
    };
  };

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    displayManager = {
      startx.enable = false;
      lightdm.enable = false;
    };

    # TODO: Extract i18n
    xkb = {
      layout = "ch,de";
      options = "eurosign:e";
    };

    updateDbusEnvironment = true;
  };
}
