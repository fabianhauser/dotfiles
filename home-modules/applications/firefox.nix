{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
  };
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "true";
    MOZ_DBUS_REMOTE = "1";
  };
}
