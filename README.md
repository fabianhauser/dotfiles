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

### Measured Boot (lanzaboote autoEnrollKeys + systemd-pcrlock)

Hosts that set `dotfiles.secureBoot.measured.enable` (currently `tschingel`) skip the manual
`sbctl create-keys`/`enroll-keys` steps above: lanzaboote generates the Secure Boot keys and
enrolls them via systemd-boot, and locks the TPM2 policy to a `systemd-pcrlock` policy
(PCRs 0/4/7) instead of static PCRs. `configurationLimit` is capped at 8.

**Migrating an existing host** (e.g. `speer`, `ochsenchopf`) to measured boot:

1. Set on the host:
   ```nix
   dotfiles.secureBoot.measured = {
     enable = true;
     cryptenrollDevice = "<the host's LUKS2 block device>"; # optional; enables hands-off re-enroll
   };
   ```
   and keep `configurationLimit <= 8` (fewer stored generations on the ESP).
1. `dotfiles-nixos-switch`, then reboot so the keys are auto-enrolled.
1. `dotfiles-enroll-tpm` once to seed the first TPM2 slot (uses the new pcrlock policy). If
   `cryptenrollDevice` is set, lanzaboote's `autoCryptenroll` re-enrolls automatically on later
   boot-measurement changes; otherwise re-run `dotfiles-enroll-tpm` after such changes.
1. `bootctl status` to confirm Secure Boot is active.

Passphrase and SSH-in-initrd unlock remain available as fallback if the TPM policy fails.

Caveats:

- `autoCryptenroll` handles only its single `cryptenrollDevice`. On hosts with a second LUKS2
  volume (e.g. tschingel's encrypted swap), re-run `dotfiles-enroll-tpm` after boot-measurement
  changes to refresh that volume's TPM2 slot; otherwise it falls back to the passphrase prompt.
- `autoCryptenroll` retries on every boot until the first slot exists — seed it with
  `dotfiles-enroll-tpm` on a quiet boot and don't run both concurrently.
