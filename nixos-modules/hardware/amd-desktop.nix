{
  lib,
  config,
  pkgs,
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
  options.dotfiles.hardware.amd-desktop.enable =
    lib.mkEnableOption "Enable AMD Desktop Setup Support";

  config = lib.mkIf config.dotfiles.hardware.amd-desktop.enable {

    dotfiles.hardware.ecc-memory.enable = true;

    boot.kernelParams = [ "acpi_enforce_resources=lax" ];

    # The Thunderbolt card in combination with a Thinkpad Dock has power issues after suspend and boot.
    # These scripts help with some cases.
    environment.systemPackages = [ thunderboltDockRestart ];
    powerManagement.powerUpCommands = "${forceThunderboltOnScript}/bin/force-thunderbolt-power-on";

    nix.settings.max-jobs = lib.mkDefault 24;
  };
}
