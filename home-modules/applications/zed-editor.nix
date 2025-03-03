{ pkgs, lib, ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "cspell"
      "latex"
      "sql"
      "toml"
      "plantuml"

      "helm"

      "html"
      "svelte"

      "java"
      "kotlin"

    ];
    extraPackages = with pkgs; [
      nixd
      nodePackages.cspell
      direnv
    ];
    userSettings = lib.importJSON ./zed-editor/settings.json;
  };
}
