{ ... }:
{

  imports = [
    ./filesystems.nix
    ./networking.nix
    ./disko-config.nix
  ];
  facter.reportPath = ./facter.json;

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

  # Set your time zone.
  time.timeZone = "Europe/Tallinn";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like fi:le locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
