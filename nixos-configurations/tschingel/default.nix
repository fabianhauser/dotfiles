{ ... }:
{

  imports = [
    ./networking.nix
    ./disko-config.nix
  ];
  facter.reportPath = ./facter.json;
  dotfiles.hardware.thinkpad-x1-gen13.enable = true;
  dotfiles.desktop.enable = true;

  system.stateVersion = "26.05";
}
