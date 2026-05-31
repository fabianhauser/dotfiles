{ lib, config, ... }:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    services.xserver.windowManager.i3.enable = false;

    services.displayManager = {
      defaultSession = "sway";
      gdm = {
        enable = true;
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
      xkb.layout = "us(altgr-intl)";

      updateDbusEnvironment = true;
    };
  };
}
