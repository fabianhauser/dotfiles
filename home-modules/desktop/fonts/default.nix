{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      font-awesome
    ];
  };
}
