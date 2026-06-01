{
  lib,
  ...
}:
{
  imports = [
    ./desktop-environment.nix
    ./greeter.nix
    ./office-suite.nix
    ./security.nix
    ./video.nix
  ];

  options.dotfiles.desktop.enable = lib.mkEnableOption "graphical desktop environment";
}
