{
  ...
}:

{
  #boot.kernelModules = [ "v4l2loopback" ];
  #boot.extraModulePackages = [ pkgs.linuxPackages_latest.v4l2loopback ];

  programs.steam.enable = true;
}
