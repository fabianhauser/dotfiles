{ lib, config, ... }:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    programs.kitty = {
      enable = true;
      settings = {
        term = "xterm";
        background_opacity = lib.mkForce "0.7";
      };
    };
  };
}
