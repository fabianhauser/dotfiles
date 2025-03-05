{ pkgs, lib, ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "typos"
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
      direnv
      typos
      typos-lsp
    ];
    userSettings = lib.importJSON ./zed-editor/settings.json;
  };
}
