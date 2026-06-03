{
  inputs,
  lib,
  pkgs,
  osConfig ? { },
  ...
}:
{
  imports = lib.optional (!(osConfig ? stylix)) inputs.stylix.homeModules.stylix;

  stylix = lib.mkIf (!(osConfig ? stylix)) {
    enable = true;
    image = ./desktop/environment/closed_farn.JPG;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
    };
  };
}
