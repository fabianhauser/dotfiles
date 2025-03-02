{ ... }:
{
  virtualisation = {
    # TODO: This should probably be somewhere else.
    docker = {
      enable = true;
      enableOnBoot = false;
    };
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    options kvm_intel emulate_invalid_guest_state=0
    options kvm ignore_msrs=1
  '';
}
