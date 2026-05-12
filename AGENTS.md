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

## Important Notes

- Secure Boot and TPM disk unlock require manual setup steps
- Private configurations in `private/` directory (not in main repo)
- Uses lanzaboote for Secure Boot signing
- Attic cache configured for CI and local builds
- **Flake evaluation requires clean git tree**: Run `git add` on new/modified files before `nix flake check` to avoid path resolution errors
