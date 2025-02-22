{ pkgs, ... }:
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
    userSettings = {
      assistant = {
        default_model = {
          provider = "openai";
          model = "o1-mini";
        };
        version = "2";
      };
      vim_mode = false;
      ui_font_size = 16;
      buffer_font_size = 16;
      theme = {
        mode = "system";
        light = "Andromeda";
        dark = "One Dark";
      };
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      languages = {
        Markdown.remove_trailing_whitespace_on_save = false;
        Markdown-Inline.remove_trailing_whitespace_on_save = false;
      };
    };
  };
}
