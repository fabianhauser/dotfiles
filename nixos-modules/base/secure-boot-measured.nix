{ config, lib, ... }:
let
  cfg = config.dotfiles.secureBoot.measured;
in
{
  options.dotfiles.secureBoot.measured = {
    enable = lib.mkEnableOption ''
      lanzaboote automatic Secure Boot key generation/enrollment and measured boot tpm2 unlock.
    '';

    device = lib.mkOption {
      type = lib.types.str;
      example = "/dev/disk/by-partlabel/disk-primary-keystore";
      description = ''
        LUKS2 device handed to lanzaboote's autoCryptenroll for hands-off systemd-pcrlock
        TPM2 re-enrollment whenever the boot measurements change. autoCryptenroll only
        maintains an already-present TPM2 slot, so seed the first slot once with
        dotfiles-enroll-tpm.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    boot.lanzaboote = {
      autoGenerateKeys.enable = true;
      autoEnrollKeys.enable = true;

      # systemd-pcrlock caps the ESP at 8 generations.
      configurationLimit = 8;
      measuredBoot = {
        enable = true;
        # TODO(tpm-pin): enroll with --tpm2-with-pin via sops-nix (#125).
        pcrs = [
          0
          4
          7
        ];
        autoCryptenroll = {
          enable = true;
          inherit (cfg) device;
        };
      };
    };
  };
}
