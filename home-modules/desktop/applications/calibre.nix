{ lib, config, ... }:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    programs.calibre.enable = true;
  };
}
