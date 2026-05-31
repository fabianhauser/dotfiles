{ lib, config, ... }:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    programs.kitty = {
      enable = true;
      settings.term = "xterm";
    };
    catppuccin.kitty.enable = true;
  };
}
