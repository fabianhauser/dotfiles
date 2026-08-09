---
name: sway-spaces
description: 'How the sway "spaces" and "projects" workspace model in this dotfiles repo works (naming, multi-monitor layout, waybar indicators, per-project wallpaper). TRIGGER when working on sway/waybar workspace behavior here: editing sway-spaces.nix, waybar.nix, sway.nix, or kanshi.nix, or touching swaysome, the space/project subcommands, the waybar space/project modules, or per-project backgrounds.'
---

## Model

Workspaces are named `<space><project>` — two digits, e.g. `31` = space 3,
project 1 (space 0 makes single-digit names like `3`). sworkstyle may append
icons/separators after the digits; only the leading digits are stable.

Mapping to swaysome's own vocabulary: **space** = first digit = swaysome
*group* (a per-output column); **project** = second digit = swaysome
*workspace* (a row spanning outputs). This distinction lives entirely inside
[the swaysome fork](https://github.com/fabianhauser/swaysome) now — see
`FORK.md`/`CLAUDE.md` in that repo (`/home/fhauser/private/fabianhauser/swaysome`
locally) for its internal architecture (state locking, composed project
operations, the IPC event/watch layer). This dotfiles repo only *consumes*
swaysome's CLI; it holds no space/project parsing or state logic of its own
anymore — `swaysome`'s own `num` field from sway's IPC (parsed as an integer,
never derived by regex from the display name) is the only source of truth.

The one exception is display-only: `sworkstyle` may append a cosmetic icon
suffix to a workspace's name, and swaysome's `watch-space` strips the leading
digit run from that name to keep the suffix. That's a display-text operation,
not a coordinate-parsing one.

`swaysome` subcommands: `focus-space`/`move-to-space` (aliases of
`focus-group`/`move-to-group`), `focus-project`/`move-to-project`,
`init`/`rearrange-workspaces`, `list-projects`,
`set-project-name`/`get-project-name`/`clear-project-name`, `status`,
`watch-space <N>`/`watch-project`. Run `swaysome --help` for the full surface.

## Multi-monitor layout

A project is the active "row" across the whole session. A single monitor hosts
**several spaces** of that project; only one is visible per monitor at a time,
the rest stay live but hidden. E.g. in project 1: monitor 1 holds `31`,`41`
(one visible), monitor 2 holds `51`,`61`,`71`.

## Where things live

- `sway-spaces.nix` — wires `inputs.swaysome` (a `git+https://git.qo.is/...`
  flake input pinned to a rev, see `flake.nix`/`flake.lock` — not a local
  `path:` input) as the package, plus `spacesMenu`
  (`dotfiles-sway-spaces-menu`): a tiny fuzzel-only glue script
  for the project-switch and rename menus (`swaysome list-projects`/
  `set-project-name`/`get-project-name` piped through `fuzzel --dmenu`). No
  parsing logic lives here — `swaysome` does all the state I/O and waybar tick
  notification natively.
- `waybar.nix` — `custom/space-N` and `custom/project` modules `exec`
  `swaysome watch-space N`/`watch-project` directly (native long-running
  watchers, replacing the old Python i3ipc scripts), with `on-click`/
  `on-click-right` calling `swaysome`/`spacesMenu` subcommands. Both module
  kinds set `restart-interval` so waybar respawns a watcher that exits on a
  transient sway hiccup (waybar does not auto-restart continuous `exec`
  scripts otherwise). CSS is unchanged — the JSON contract (`class`:
  `focused`/`visible`/`urgent`/`empty`) is preserved exactly by
  `swaysome watch-space`.
- `sway.nix` — keybindings call `swaysome`/`spacesMenu` subcommands directly
  (no wrapper script). `workspaceBgScript` stays Python (separate concern:
  swaybg process/image-cache management) but derives the project from the
  workspace's live `num` field directly, guarding `num == -1` (sway's
  "unnumbered workspace" sentinel — Python's `-1 % 10 == 9`, so an unguarded
  modulo would silently apply project 9's wallpaper instead of skipping).
- `kanshi.nix` — profile `exec` calls `swaysome rearrange-workspaces` on
  monitor layout changes.

## Updating swaysome

Fix bugs in the checkout at `/home/fhauser/private/fabianhauser/swaysome`
(see its `HACKING.md` for how to run its tests/lints). Since the flake input
is a pinned remote rev, not `path:`, a fix isn't picked up by just committing
locally:

1. Commit in the swaysome checkout, then `git push origin master`.
1. In dotfiles, run `nix flake lock --update-input swaysome` to bump the pin
   in `flake.lock`.
1. Rebuild (`nixos-rebuild build --flake .`) and commit the `flake.lock`
   change.

## State

Session-only, in a single file at `$XDG_RUNTIME_DIR/swaysome/state.json`
(current project, last-focused space per project, project names), owned
entirely by the swaysome fork — see its `FORK.md` for the locking design.
Renaming a project sends a native sway tick (`swaysome`'s `send_tick`, no
`swaymsg` shell-out) to refresh the waybar project module.
