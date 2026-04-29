# Temporary override: apply https://github.com/NixOS/nixpkgs/pull/514576
# Remove this file (and its import in ./default.nix) once the PR merges into
# nixos-unstable and flake.lock has been updated.
{
  nixpkgs.overlays = [
    (_final: prev: {
      efitools = prev.efitools.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ./efitools-objcopy-output-target.patch
        ];
      });
    })
  ];
}
