{
  nixpkgs.overlays = [
    # Fixes checksumdir's missing [build-system] table, which otherwise
    # produces a version-mismatched wheel and fails the build.
    # https://github.com/NixOS/nixpkgs/pull/546402
    (_final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (pyFinal: pyPrev: {
          checksumdir = pyPrev.checksumdir.overridePythonAttrs (old: {
            nativeBuildInputs = builtins.filter (p: p != pyPrev.setuptools) old.nativeBuildInputs ++ [
              pyFinal.poetry-core
            ];
            postPatch = (old.postPatch or "") + ''
              cat >>pyproject.toml <<EOF

              [build-system]
              requires = ["poetry-core"]
              build-backend = "poetry.core.masonry.api"

              EOF
            '';
          });
        })
      ];
    })
  ];
}
