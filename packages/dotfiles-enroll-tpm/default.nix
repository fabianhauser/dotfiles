{
  writeShellApplication,
  systemd,
  nix,
  jq,
  self,
}:
writeShellApplication {
  name = "dotfiles-enroll-tpm";
  meta.description = ''
    Enroll a TPM2 policy to unlock the host's LUKS device(s).

    Every boot.initrd.luks.devices entry is enrolled. Hosts with lanzaboote
    measured boot use the systemd-pcrlock policy; legacy hosts bind static PCRs
    (0 firmware, 2 pluggable code, 7 SecureBoot state, 12 kernel cmdline).

    On measured-boot hosts this only seeds the first TPM2 slot; lanzaboote's
    autoCryptenroll maintains it afterwards.
  '';
  runtimeInputs = [
    systemd
    nix
    jq
  ];
  text = ''
    host="${self}#nixosConfigurations.$HOSTNAME.config"
    measured="$(nix eval "$host.boot.lanzaboote.measuredBoot.enable")"

    if [ "$measured" = "true" ]; then
      policy="$(nix eval --raw "$host.boot.lanzaboote.measuredBoot.pcrlockPolicy")"
      # TODO(tpm-pin): add --tpm2-with-pin once the PIN is managed via sops-nix (#125).
      pcr_args=(--tpm2-pcrlock="$policy")
    else
      pcr_args=(--tpm2-pcrs=0+2+7+12)
    fi

    mapfile -t devices < <(
      nix eval --json "$host.boot.initrd.luks.devices" \
        --apply 'devs: map (d: d.device) (builtins.attrValues devs)' | jq -r '.[]'
    )

    for device in "''${devices[@]}"; do
      echo -en "Enroll TPM2 into LUKS device $device.\nContinue? [ENTER]" && read -r
      /run/wrappers/bin/sudo systemd-cryptenroll \
        --tpm2-device=auto "''${pcr_args[@]}" --wipe-slot=tpm2 "$device"
    done
  '';
}
