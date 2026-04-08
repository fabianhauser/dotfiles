{ ... }:
{
  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  # Options to make tray work
  # TODO: Upstream with .tray option, like gammastep
  systemd.user.services.nextcloud-client = {
    Unit = {
      Requires = [ "tray.target" ];
      After = [ "tray.target" ];
    };
    Service.Environment = [ "XDG_CURRENT_DESKTOP=Unity" ];
  };
}
