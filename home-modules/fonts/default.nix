{ pkgs, ... }:
{
  fonts.fontconfig = {
    enable = true;
  };
  home.packages = with pkgs; [
    powerline-fonts
    font-awesome
  ]; # Generated with `cd /home/fhauser/projects/nixos/nixpkgs/pkgs/data/fonts; echo *`
}
