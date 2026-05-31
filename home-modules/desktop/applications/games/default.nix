{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    home.packages = with pkgs; [
      supertuxkart
      wesnoth
    ];
  };
}
