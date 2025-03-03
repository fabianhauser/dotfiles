{
  config,
  lib,
  ...
}:

{
  services.pcscd.enable = true;

  # Make pam accept both password and fingerprint
  security.pam.services.swaylock.rules.auth = lib.mkIf config.services.fprintd.enable {
    fprintd.order = 11601;
    unix.args = [ "nullok" ];
  };
}
