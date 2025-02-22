{
  ...
}:
{

  services.xserver.windowManager.i3.enable = false;

  services.displayManager = {
    defaultSession = "sway";
  };

  # Enable touchpad support.
  services.libinput.enable = true;

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = false;
    displayManager = {
      startx.enable = false;
      lightdm.enable = false;
      gdm = {
        enable = true;
        wayland = true;
      };
    };

    # TODO: Extract i18n
    xkb = {
      layout = "ch,de";
      options = "eurosign:e";
    };

    updateDbusEnvironment = true;
  };
}
