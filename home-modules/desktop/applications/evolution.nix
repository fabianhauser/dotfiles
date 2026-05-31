{ lib, config, ... }:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    dconf.settings."org/gnome/evolution-data-server/calendar".notify-enable-audio = false;
  };
}
