{ lib, config, ... }:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    programs.gphoto2.enable = true;
    users.users.fhauser.extraGroups = [ "camera" ];
  };
}
