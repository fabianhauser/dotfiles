{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.dotfiles.work;
in
{

  imports = [
    inputs.private.homeModules.work
  ];

  options.dotfiles.work.enable = mkEnableOption "Enable work configuration";

  config = mkIf cfg.enable {
    programs.bash.initExtra = ''
      source "${config.home.homeDirectory}/.profile"
    '';
    xdg.mimeApps.defaultApplications = lib.mkForce {
      "text/html" = "google-chrome.desktop";
      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "x-scheme-handler/about" = "google-chrome.desktop";
      "x-scheme-handler/unknown" = "google-chrome.desktop";
    };
  };
}
