{
  lib,
  config,
  ...
}:
{

  options.dotfiles.hardware.thinkpad-x1-gen13.enable =
    lib.mkEnableOption "Enable ThinkPad X1 Gen13 Support";

  config = lib.mkIf config.dotfiles.hardware.thinkpad-x1-gen13.enable {

    # TODO: Check AX200 issues
    hardware.enableAllFirmware = true;
    hardware.enableRedistributableFirmware = true;
    nixpkgs.config.allowUnfree = true;

    # CPU Configuration
    services.throttled.enable = true;
    powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  };
}
