{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.dotfiles.desktop;
in
{
  imports = [
    ./gammastep.nix
    ./kanshi.nix
    ./mako.nix
    ./sway.nix
    ./swaylock.nix
    ./waybar.nix
  ];

  config = mkIf cfg.enable {
    services = {
      network-manager-applet.enable = true;
      pasystray.enable = true;
      blueman-applet.enable = true;
    };
  };
}
