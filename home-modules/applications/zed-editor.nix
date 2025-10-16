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
      claude-code
      nodePackages_latest.nodejs
    ];
    userSettings = lib.importJSON ./zed-editor/settings.json;
  };
}
