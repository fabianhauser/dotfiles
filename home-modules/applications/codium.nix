{ pkgs, ... }:

{
  programs.vscodium = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      mkhl.direnv
      jnoortheen.nix-ide
      # anthropic.claude-code # Anthropic changes same versions, so hashes don't match regularly :(
    ];
  };
}
