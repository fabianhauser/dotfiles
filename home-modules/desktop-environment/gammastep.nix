{ lib, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.dotfiles.desktop-environment;
in
{
  services.gammastep = mkIf cfg.enable {
    enable = true;
    settings.general.brightness-night = "0.9";

    temperature.day = 6300;
    temperature.night = 5500;

    latitude = "47.2";
    longitude = "8.8";
    tray = true;
  };
}
