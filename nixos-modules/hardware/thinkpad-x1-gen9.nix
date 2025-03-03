{
  lib,
  config,
  ...
}:
{

  options.dotfiles.hardware.thinkpad-x1-gen9.enable =
    lib.mkEnableOption "Enable ThinkPad X1 Gen9 Support";

  config = lib.mkIf config.dotfiles.hardware.thinkpad-x1-gen9.enable {

    dotfiles.hardware.modem-em120r-gl.enable = true;

    # CPU Configuration
    services.throttled.enable = true;
    powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  };
}
