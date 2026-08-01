# Fabian's Dotfiles

## System Setup

Deploying a host with nixos-anywhere. Example: `tschingel`.

### 1. Prepare target

Boot the NixOS installer ISO, `sudo passwd root`, get the IP with `ip a`.

`systemctl reboot --firmware-setup`: clear the Secure Boot keys to enter **Setup Mode**. Vendor-specific,
see [lanzaboote docs](https://github.com/nix-community/lanzaboote/blob/master/docs/getting-started/enable-secure-boot.md).
Required before installing — the keys are enrolled on first boot, and firmware not in Setup Mode silently
refuses them.

### 2. Check

- `private/` submodule is checked out (flake eval needs it)
- `ls -l /dev/disk/by-id/` matches `disk` in `nixos-configurations/$REMOTE_HOSTNAME/disko-config.nix`
- `$REMOTE_IP` is right — disko wipes it

### 3. Install

```bash
nix develop
REMOTE_HOSTNAME=tschingel
REMOTE_IP=<ip>
LUKS_KEYFILE="$(mktemp)"

# TODO(#125): use `sops exec-file` once the passphrase lives in sops-nix.
pwgen -s -1 --ambiguous 20 1 > "$LUKS_KEYFILE"
cat "$LUKS_KEYFILE"  # ⚠️ save in password manager: this is the interactive unlock fallback

ssh root@$REMOTE_IP true  # accept host key

# ⚠️ wipes all disks on $REMOTE_IP
nixos-anywhere \
  --flake ".#$REMOTE_HOSTNAME" \
  --build-on remote \
  --copy-host-keys \
  --generate-hardware-config nixos-facter ./nixos-configurations/$REMOTE_HOSTNAME/facter.json \
  --disk-encryption-keys /tmp/secret.key "$LUKS_KEYFILE" \
  root@$REMOTE_IP

# --disk-encryption-keys <remote> <local> # the remote path must match disko's `passwordFile` (\n stripped)
# --ssh-option "ProxyJump=user@jumphost"
#  --no-substitute-on-destination # Copy over deps

shred -u "$LUKS_KEYFILE"
git add nixos-configurations/$REMOTE_HOSTNAME/facter.json
```

### 4. Secure Boot

nixos-anywhere reboots into the new system. Boot 1 generates and stages the keys: unlock LUKS with the
passphrase, wait for `prepare-sb-auto-enroll.service`, then `systemctl reboot`. systemd-boot enrolls them
into the firmware (keeping the Microsoft keys) and reboots once more.

```bash
bootctl status  # Secure Boot: enabled (user)
sbctl verify    # /boot/EFI/nixos/kernel*.efi is not supposed to be signed
```

Not enrolled? The firmware left Setup Mode — `systemctl reboot --firmware-setup`, clear the keys, retry.

### 5. TPM unlock

Only works once Secure Boot is active (step 4).

```bash
dotfiles-enroll-tpm   # prompts for the LUKS passphrase
systemctl reboot
```

Seeds the first TPM2 slot; `auto-cryptenroll.service` and `systemd-pcrlock` maintain it afterwards.
[See source for details](./packages/dotfiles-enroll-tpm).

### Secure Boot & TPM Disk Unlock

See the [lanzaboote documentation](https://github.com/nix-community/lanzaboote/tree/master/docs) for more information on how to enable secure boot.

- With `nixos-rebuild {switch|boot}`, new EFI files will be automatically signed.
- In case your firmware or boot process changes, you need to insert the luks password manually.
  - This should **not** happen just because of kernel updates (but might with boot param changes.)
  - After a successful boot, you can re-enroll the new secure state with `dotfiles-enroll-tpm`.

### Measured Boot (lanzaboote autoEnrollKeys + systemd-pcrlock)

Hosts that set `dotfiles.secureBoot.measured.enable` (currently `tschingel`) need no manual
`sbctl create-keys`/`enroll-keys`: lanzaboote generates the Secure Boot keys and enrolls them via
systemd-boot, and binds the TPM2 policy to a `systemd-pcrlock` policy (PCRs 0/4/7) instead of static
PCRs. `configurationLimit` is capped at 8, which is the pcrlock limit.

**Migrating an existing host** (e.g. `speer`, `ochsenchopf`) to measured boot:

1. Set on the host:
   ```nix
   dotfiles.secureBoot.measured = {
     enable = true;
     device = "<the host's LUKS2 block device>";
   };
   ```
1. `dotfiles-nixos-switch`, then reboot so the keys are auto-enrolled.
1. `bootctl status` to confirm Secure Boot is active — `auto-cryptenroll.service` does not run before it
   is.
1. `dotfiles-enroll-tpm` once to seed the first TPM2 slot with the pcrlock policy. Afterwards
   `systemd-pcrlock` updates the policy in place in the same TPM NV index on every switch, so
   boot-measurement changes need no re-enrollment.

The passphrase remains available as fallback if the TPM policy fails.

Caveats:

- `auto-cryptenroll.service` unlocks via `--unlock-tpm2-device=auto`, so it cannot bootstrap itself: it
  retries every boot until `dotfiles-enroll-tpm` has seeded a slot, then succeeds once and is disabled by
  the `/var/lib/auto-cryptenroll/1` sentinel. Don't run both concurrently.
- It maintains only its single `device`. Hosts with more than one `boot.initrd.luks.devices` entry need
  `dotfiles-enroll-tpm` for the others, which iterates over all of them.
