{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    services.pcscd.enable = true;
  };
}
