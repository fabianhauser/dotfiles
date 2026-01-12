{ lib, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.dotfiles.desktop-environment;
in
{
  config = mkIf cfg.enable {
    services.mako = {
      enable = true;
      settings = {
        border-size = 0;
        default-timeout = 1500;
        #ignoreTimeout = true;
        #width = 300;
        #height = 100;
        #font = "monospace 10";
      };
    }; # TODO
    catppuccin.mako.enable = true;
  };
}
