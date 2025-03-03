{ ... }:
{

  imports = [
    ./filesystems.nix
    ./networking.nix
    ./disko-config.nix
  ];
  facter.reportPath = ./facter.json;
  dotfiles.hardware.amd-desktop.enable = true;

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
