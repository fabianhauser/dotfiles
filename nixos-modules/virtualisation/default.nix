{ config, ... }:
{
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
    };
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  boot.extraModprobeConfig =
    let
      isIntel = config.hardware.cpu.intel.updateMicrocode;
      isAmd = config.hardware.cpu.amd.updateMicrocode;
      procName =
        if isIntel then
          "intel"
        else if isAmd then
          "amd"
        else
          "";
    in
    if isIntel || isAmd then
      ''
        options kvm_${procName} nested=1
        options kvm_${procName} emulate_invalid_guest_state=0
        options kvm ignore_msrs=1
      ''
    else
      "";
}
