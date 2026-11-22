{ ... }:
{
  home.enableNixpkgsReleaseCheck = false;

  imports = [
    ./git.nix
    ./gpg.nix
    ./shell.nix
    ./ssh.nix
    ./vim.nix
  ];
}
