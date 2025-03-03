{
  config,
  lib,
  ...
}:
{
  options.dotfiles.hardware.ecc-memory.enable = lib.mkEnableOption "Enable ECC Memory Support";

  config = lib.mkIf config.dotfiles.hardware.ecc-memory.enable {

    hardware.rasdaemon.enable = true;
  };
}
