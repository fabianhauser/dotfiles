{
  lib,
  pkgs,
  modulesPath,
  ...
}:
let
  thunderboltDevices = ''
    THUNDERBOLT_DEVICES="$(${pkgs.pciutils}/bin/lspci -D | ${pkgs.gnugrep}/bin/grep -i thunderbolt | cut --delimiter=' ' --fields=1)"
  '';
  forceThunderboltOnScript = pkgs.writeScriptBin "force-thunderbolt-power-on" ''
    #!${pkgs.stdenv.shell}

    ${thunderboltDevices}

    echo "Force PCI power on all thunderbolt devices"
    for DEVICE in $THUNDERBOLT_DEVICES; do
      echo 'on' > "/sys/bus/pci/devices/$DEVICE/power/control"
    done
  '';
  thunderboltDockRestart = pkgs.writeScriptBin "thunderbolt-dock-restart" ''
    #!${pkgs.stdenv.shell}

    ${thunderboltDevices}

    echo "Force PCI remove on all thunderbolt devices"
    for DEVICE in $THUNDERBOLT_DEVICES; do
      echo 1 > /sys/bus/pci/devices/$DEVICE/remove
      echo "Dropped device $DEVICE"
    done


    echo 'Please re-plug the dock and confirm [enter]'
    read

    echo 'Rescanning PCI devices...'
    echo 1 > /sys/bus/pci/rescan

    echo 'Done.'
  '';
in
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "xhci_pci"
    "ahci"
    "virtio-pci"
    "igb"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-amd"
    "uhid"
  ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [ "acpi_enforce_resources=lax" ];

  environment.systemPackages = [ thunderboltDockRestart ];

  hardware.cpu.amd.updateMicrocode = true;
  nix.settings.max-jobs = lib.mkDefault 24;

  powerManagement.powerUpCommands = "${forceThunderboltOnScript}/bin/force-thunderbolt-power-on";
}
