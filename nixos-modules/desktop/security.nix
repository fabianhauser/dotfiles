{
  ...
}:

{
  services.pcscd.enable = true;

  # Make pam accept both password and fingerprint
  security.pam.services.swaylock.rules.auth = {
    fprintd.order = 11601;
    unix.args = [ "nullok" ];
  };
}
