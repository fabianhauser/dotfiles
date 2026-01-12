{
  config,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.dotfiles.desktop-environment;
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

  options.dotfiles.desktop-environment.enable = mkEnableOption "Enable desktop-environment configuration";

  config = mkIf cfg.enable {
    services = {
      network-manager-applet.enable = true;
      pasystray.enable = true;
      blueman-applet.enable = true;
    };
  };

}
