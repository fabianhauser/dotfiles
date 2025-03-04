{ pkgs, ... }:
{
  home.packages = with pkgs; [
    anki
    ki
  ];
}
