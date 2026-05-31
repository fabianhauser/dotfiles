{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
    };
    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_DBUS_REMOTE = "1";
    };
  };
}
