{
  ...
}:
{
  imports = [
    ./applications
    ./theme
    ./multimedia.nix
    ./mimetypes.nix
  ];

  systemd.user.targets.tray.Unit = {
    Description = "Home Manager System Tray";
    Requires = [ "graphical-session-pre.target" ];
  };
}
