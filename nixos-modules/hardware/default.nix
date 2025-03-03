{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{

  imports = [
    inputs.nixos-facter-modules.nixosModules.facter
    ./ecc-memory.nix
    ./amd-desktop.nix
    ./modem-em120r-gl.nix
    ./thinkpad-x1-gen9.nix
    ./printing.nix
  ];

  # Enable touchpad support.
  services.libinput.enable = true;

  services.fwupd.enable = true;

  services.blueman.enable = true;

  # Enable sound.
  nixpkgs.config.pulseaudio = true;

  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-compute-runtime
        intel-media-driver
        libvdpau-va-gl
        vaapiVdpau
      ];

    };
    acpilight.enable = true;
    bluetooth = {
      enable = true;
      package = pkgs.bluez;
    };
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };

  services.hardware.bolt.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = config.powerManagement.enable;

  programs.light.enable = true;
  programs.adb.enable = true;

  services.fprintd = lib.mkIf config.facter.detected.fingerprint.enable {
    enable = true;
    package = pkgs.fprintd-tod;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-vfs0090;
    };
  };
}
