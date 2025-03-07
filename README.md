# Fabian's Dotfiles

## System Setup

🐈‍⬛

### Secure Boot & TPM Disk Unlock

See [lanzaboote documentation](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md) for more information on how to enable secure boot.

1. Create secure boot keys before switching to the system configuration: `sudo sbctl create-keys`
1. After applying the system configuration, verify signatures: `sudo sbctl verify`
   - `/boot/EFI/nixos/kernel*.efi` is not supposed to be signed.
1. Activate enrollment of new Secure Boot key in the UEFI: `systemctl reboot --firmware-setup`
   - Depends on vendor, see [lanzaboote docs](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md#part-2-enabling-secure-boot)
1. Boot linux, run `sudo sbctl enroll-keys --microsoft`
   - Keeps microsoft keys - some vendor firmware and Windows dual boot require this.
1. Activate secure boot: `systemctl reboot --firmware-setup`
1. Boot your system and verify that a secure boot worked with: `bootctl status`
1. After enabling secure boot, enroll the boot PCR measurement based LUKS unlock: `dotfiles-enroll-tpm`
   - [See source for details](./packages/dotfiles-enroll-tpm).

- With `nixos-rebuild {switch|boot}`, new EFI files will be automatically signed.
- In case your firmware or boot process changes, you need to insert the luks password manually.
  - After a successful boot, you can re-enroll with `dotfiles-enroll-tpm`.
