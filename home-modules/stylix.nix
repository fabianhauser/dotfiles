{
  inputs,
  lib,
  pkgs,
  osConfig ? { },
  ...
}:
let
  inherit (lib) mkIf mkMerge optional;
  isStandalone = !(osConfig ? stylix);
in
{
  imports = optional isStandalone inputs.stylix.homeModules.stylix;

  stylix = mkMerge [
    { targets.wayprompt.enable = false; }
    (mkIf isStandalone {
      enable = true;
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
    })
  ];
}
