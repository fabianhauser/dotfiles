{ pkgs, ... }:
{
  programs.opencode = {
    enable = true;
    extraPackages = [ pkgs.opencode-claude-auth ];
  };
}
