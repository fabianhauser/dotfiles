# OpenCode Agent Instructions for Dotfiles

## Repository Overview

- NixOS-based dotfiles repository using flakes
- Manages multiple NixOS hosts (speer, ochsenchopf) and home configurations
- Uses flake-parts for modular configuration

## Key Commands

- `nix develop`: Enter development shell with all tools
- `nix flake check`: Check flake inputs and outputs
- `nix fmt`: Format Nix files
- `nix-fast-build --no-nom --max-jobs 1 --skip-cached --attic-cache fabianhauser:dotfiles`: Run CI checks locally
- `nixos-rebuild build --flake .`: Check if NixOS configuration builds
- `dotfiles-nixos-switch`: Apply NixOS configuration (preferred over nixos-rebuild switch)
- `dotfiles-enroll-tpm`: Enroll TPM PCR registers for LUKS disk unlock

## Build & Test

- CI uses Nix flakes with attic cache
- No traditional test suite - validation happens through Nix builds
- Formatting enforced via treefmt (nixfmt, deadnix, etc.)

## Architecture

- `flake.nix`: Main entrypoint defining inputs and outputs
- `nixos-configurations/`: Host-specific configurations
- `home-configurations/`: User-specific configurations
- `packages/`: Custom packages like dotfiles-enroll-tpm
- `nixos-modules/` and `home-modules/`: Reusable modules

## Home-Manager & NixOS Configuration Structure

**NixOS hosts** (`nixos-configurations/`): `speer`, `ochsenchopf` — both use the `fhauser` user, each automatically picks up `home-configurations/fhauser.nix` via ez-configs.

**Home-manager entry points:**

- `home-configurations/fhauser.nix` — primary user config for both NixOS hosts
- `home-configurations/work.nix` — standalone home-manager deployment (non-NixOS); imports from `inputs.private`

**Module tree** (`home-modules/`):

- `default.nix` — root; imports all sub-modules: base, stylix, desktop, development, work
- `base/` — always active: git, shell, ssh, vim, gpg, core packages (ripgrep, curl, rsync, …)
- `desktop/` — gated by `dotfiles.desktop.enable`; sub-dirs: applications/, environment/ (sway, waybar, kanshi), security/, theme/, fonts/, multimedia/
- `development/` — gated by `dotfiles.development.enable`; contains claude-code/, gh.nix, opencode.nix, psql.nix
- `work/` — gated by `dotfiles.work.enable`; imports from `inputs.private.homeModules.work`

**Enable pattern:** features use `lib.mkEnableOption` + `lib.mkIf config.dotfiles.<feature>.enable`

**Private config:** sensitive data (git identities, work config) lives in `inputs.private` — not present in this repo.

## Styling

- Waybar workspace buttons can be targeted via `#sway-workspace-N` CSS IDs (e.g. `#sway-workspace-0 { background-color: ...; }`)
- Stylix base16 colors are available in Nix expressions as `config.lib.stylix.colors.withHashtag.baseXX` (returns hex string with `#` prefix)
- In waybar/GTK CSS, stylix colors are available as CSS custom properties: `@base08`, `@base0A`, etc.
- Sway has no native per-workspace background support; implement with an event-driven script using `swaymsg -t subscribe '["workspace"]'` and `swaymsg "output '*' bg <hex> solid_color"`
- Embed stylix colors into bash scripts at build time using `pkgs.writeShellScript` with Nix `${config.lib.stylix.colors.withHashtag.baseXX}` interpolation — colors update automatically with theme changes

## Important Notes

- Secure Boot and TPM disk unlock require manual setup steps
- Private configurations in `private/` directory (not in main repo)
- Uses lanzaboote for Secure Boot signing
- Attic cache configured for CI and local builds
- **Flake evaluation requires clean git tree**: Run `git add` on new/modified files before `nix flake check` to avoid path resolution errors
- Configuration of Claude Code, OpenCode and other AI tooling is in this repository - configured often via home-manager.
