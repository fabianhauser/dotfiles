{
  lib,
  pkgs,
  modulesPath,
  hardwareModules,
  pkgFccUnlock,
  ...
}:
{

  imports = with hardwareModules; [
    (modulesPath + "/installer/scan/not-detected.nix")
    hardwareModules.lenovo-thinkpad-x1-9th-gen
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
    "ahci"
    "usbhid"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.initrd.kernelModules = [ "dm-snapshot" ]; # TODO: This should be moved to defaults

  environment.systemPackages = with pkgs; [
    modemmanager
    libmbim
  ];

  environment.etc."ModemManager/fcc-unlock.d/1eac:1001" = {
    source = "${pkgFccUnlock}/bin/fcc-unlock";
  };

  # CPU Configuration
  hardware.cpu.intel.updateMicrocode = true;
  services.throttled.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
