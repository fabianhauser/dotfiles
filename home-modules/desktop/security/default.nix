{ lib, config, ... }:
{
  imports = [
    ./gpg.nix
    ./ssh.nix
  ];

  options.dotfiles.desktop.security.enable = lib.mkEnableOption "YubiKey and GPG security setup";

  config = lib.mkIf config.dotfiles.desktop.security.enable { };
}
