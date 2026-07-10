{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.dotfiles.desktop;
  swaysomePkg = inputs.swaysome.packages.${pkgs.stdenv.hostPlatform.system}.default;
  swaysome = "${swaysomePkg}/bin/swaysome";
  fuzzel = "${pkgs.fuzzel}/bin/fuzzel";

  # Pure UI plumbing around swaysome's project subcommands: a fuzzel menu to
  # switch projects, and one to rename the current project. No parsing logic;
  # `swaysome list-projects`/`get-project-name`/`set-project-name` already do
  # the state I/O and waybar tick notification natively.
  spacesMenu = pkgs.writeShellScriptBin "dotfiles-sway-spaces-menu" ''
    set -euo pipefail
    cmd="''${1:-project}"

    case "$cmd" in
      project)
        choice=$(${swaysome} list-projects | ${fuzzel} --dmenu --prompt "Project: ") || exit 0
        [[ -n "''${choice:-}" ]] || exit 0
        [[ "$choice" =~ ^([0-9]) ]] && ${swaysome} focus-project "''${BASH_REMATCH[1]}"
        ;;
      set-name)
        current=$(${swaysome} get-project-name || true)
        if [[ -n "$current" ]]; then
          name=$(printf '%s\n' "$current" | ${fuzzel} --dmenu --prompt "Name: ") || exit 0
        else
          name=$(${fuzzel} --dmenu --prompt "Name: " < /dev/null) || exit 0
        fi
        if [[ -z "$name" ]]; then
          ${swaysome} clear-project-name
        else
          ${swaysome} set-project-name "$name"
        fi
        ;;
      *)
        echo "Usage: dotfiles-sway-spaces-menu {project|set-name}" >&2
        exit 1
        ;;
    esac
  '';

  swaySpacesPkgs = {
    swaysome = swaysome;
    spacesMenu = "${spacesMenu}/bin/dotfiles-sway-spaces-menu";
  };
in
{
  config = {
    _module.args.dotfilesSwaySpaces = swaySpacesPkgs;
    home.packages = lib.mkIf cfg.enable [
      swaysomePkg
      spacesMenu
    ];
  };
}
