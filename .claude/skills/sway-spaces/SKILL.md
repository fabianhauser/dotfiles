---
name: sway-spaces
description: 'How the sway "spaces" and "projects" workspace model in this dotfiles repo works (naming, multi-monitor layout, waybar indicators, per-project wallpaper). TRIGGER when working on sway/waybar workspace behavior here: editing sway-spaces.nix, waybar.nix, or sway.nix, or touching swaysome, the space/project scripts, the waybar space/project modules, or per-project backgrounds.'
---

## Model

Workspaces are named `<space><project>` — two digits, e.g. `31` = space 3,
project 1. `space_project(name)` (in `sway-spaces.nix`, shared as `pySpaceProject`)
parses them: it pads to two digits (space 0 makes single-digit names like `3`)
and returns `(space, project)`. sworkstyle may append icons/separators after the
digits, so only the leading digits are stable.

Mapping to [swaysome](https://github.com/cdmistman/swaysome): **space** = first
digit = swaysome *group* (a per-output column); **project** = second digit =
swaysome *workspace* (a row spanning outputs). The `dotfiles-sway-spaces` wrapper
in `sway-spaces.nix` adds the project layer on top: focusing a project switches
all outputs at once and restores the last-used space per project; projects can
also be named.

## Multi-monitor layout

A project is the active "row" across the whole session. A single monitor hosts
**several spaces** of that project; only one is visible per monitor at a time,
the rest stay live but hidden. E.g. in project 1: monitor 1 holds `31`,`41`
(one visible), monitor 2 holds `51`,`61`,`71`.

## Where things live

- `sway-spaces.nix` — the `dotfiles-sway-spaces` shell wrapper (space/project
  focus+move, per-project names, last-focused-space memory) plus two i3ipc
  Python scripts exposed via `_module.args.dotfilesSwaySpaces`:
  - `waybarSpace` (`custom/space-N` modules): per-output. It reads this bar's
    output from `WAYBAR_OUTPUT_NAME`, derives the current project from the
    workspace visible on that output, then lists every space that has a
    workspace `N<project>` **on this output** — visible and hidden alike —
    emitting classes `focused`/`visible`/`urgent`/`empty`. (`WAYBAR_OUTPUT_NAME`
    is assumed present; no older-waybar fallback.)
  - `waybarProject` (`custom/project`): shows the current project number, or
    `N: name` when the project is named.
- `waybar.nix` — wires the space/project modules into the bar and holds their CSS
  (focused pill color, urgent blink, etc.).
- `sway.nix` — keybindings, `swaysome init`, and `workspaceBgScript`: sets the
  wallpaper per project via swaybg from an image in
  `~/cloud/pictures/backgrounds/<project>.*`, falling back to a per-project
  base16 color.

## State

Session-only, under `$XDG_RUNTIME_DIR/dotfiles-sway-spaces/`: project names in
`projects/<project>.json`, last-focused space per project in `last-space.json`.
A `swaymsg send_tick project-name` refreshes the waybar project module after a
rename.
