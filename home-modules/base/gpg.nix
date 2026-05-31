{ pkgs, lib, ... }:
{
  programs.gpg = {
    enable = true;
    package = pkgs.gnupg;
    settings = {
      "use-agent" = true;
      "trust-model" = "tofu";
      "no-emit-version" = true;
      "no-comments" = true;
      "sig-notation" = "issuer-fpr@notations.openpgp.fifthhorseman.net=%g";
      "keyserver" = "hkps://keys.openpgp.org";
      "keyserver-options" = "auto-key-retrieve no-honor-keyserver-url";
      "personal-cipher-preferences" = "AES256 AES192 AES CAST5";
      "cert-digest-algo" = "SHA512";
      "personal-digest-preferences" = "SHA512 SHA384 SHA256 SHA224";
      "default-preference-list" =
        "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed";
      "display-charset" = "utf-8";
      "fixed-list-mode" = true;
      "with-fingerprint" = true;
      "keyid-format" = "0xlong";
      "verify-options" = "show-uid-validity";
      "list-options" = "show-uid-validity";
    };
  };
  services.gpg-agent = {
    enable = true;
    pinentry.package = lib.mkDefault pkgs.pinentry-tty;
  };
}
