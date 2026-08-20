{
  nixpkgs.overlays = [
    # ki's test suite fails on Python 3.14 due to a gitpython/pathlib
    # incompatibility unrelated to ki's actual functionality.
    # https://github.com/langfield/ki (nativeCheckInputs pull in the
    # affected gitpython codepath during pytest collection)
    (_final: prev: {
      ki = prev.ki.overridePythonAttrs (_old: {
        doCheck = false;
      });
    })
  ];
}
