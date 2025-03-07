{
  writeShellApplication,
  systemd,
  nix,
  self,
}:
writeShellApplication {
  name = "dotfiles-enroll-tpm";
  meta.description = ''
    Enroll TPM PCR registers to unlock luks disk.

    Uses the following registers for measured boot:
      - PCR 0: Core system firmware executable code
      - PCR 2: Extended or pluggable executable code
      - PCR 7: SecureBoot state
      - PCR 12: Kernel command line, system credentials and system configuration images
  '';
  runtimeInputs = [
    systemd
    nix
  ];
  text = ''
    LUKS_DEVICE="$(nix eval --raw "${self}#nixosConfigurations.$HOSTNAME.config.disko.devices.mdadm.raid_system.content.device")"
    echo -en "Determined disko configured LUKS device at $LUKS_DEVICE.\nWould you like to continue? [ENTER]" && read -r
    /run/wrappers/bin/sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 --wipe-slot=tpm2 "$LUKS_DEVICE"
  '';
}
