# Fabian's Dotfiles

## System Setup

> 🐈‍⬛ This is how the process should be, not how it has been done... yet 😉

1. `systemctl reboot --firmware-setup`: Activate enrollment of new Secure Boot key in the UEFI
   - Depends on vendor, see [lanzaboote docs](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md#part-2-enabling-secure-boot)
1. Boot into NixOS Live system
1. TODOs at this point:
   - sops secrets encryption stuff.
   - LUKS HDD encryption with sops stuff
   - `sudo sbctl create-keys` with sops stuff.
   - See [qo.is docs](https://git.qo.is/qo.is/infrastructure/src/branch/main/nixos-configurations/setup.md) for inspiration
   - Configure attic cache substitution in nixos installer
1. ```bash
   nixos-anywhere --copy-host-keys --build-on-remote \
     --generate-hardware-config nixos-facter ./nixos-configurations/$REMOTE_HOST/facter.json
     --extra-files ... \
     --chown ... \
     --disk-encryption-keys ... \
     --flake .#$REMOTE_HOSTNAME
     root@$REMOTE_IP
   ```
   - TODO:
     - with the secrets from above
     - don't do nixos-anywhere phase reboot (secure boot keys not enrolled yet)
1. `sudo sbctl enroll-keys --microsoft`: Enroll our keys in UEFI
   - Keeps microsoft keys - some vendor firmware and Windows dual boot require this.
1. `sudo sbctl verify`: Verify Secure Boot signatures.
   - `/boot/EFI/nixos/kernel*.efi` is not supposed to be signed.
1. `systemctl reboot`: Boot into your new, signed system.
1. `bootctl status`: Verify that a secure boot worked.
   - If not, activate secure boot and try again: `systemctl reboot --firmware-setup`
1. `dotfiles-enroll-tpm`: Enroll the boot PCR measurement based LUKS unlock:
   - [See source for details](./packages/dotfiles-enroll-tpm).

### Secure Boot & TPM Disk Unlock

See [lanzaboote documentation](https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md) for more information on how to enable secure boot.

- With `nixos-rebuild {switch|boot}`, new EFI files will be automatically signed.
- In case your firmware or boot process changes, you need to insert the luks password manually.
  - This should **not** happen just because of kernel updates (but might with boot param changes.)
  - After a successful boot, you can re-enroll the new secure state with `dotfiles-enroll-tpm`.
