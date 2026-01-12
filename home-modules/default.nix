{
  ...
}:
{
  imports = [
    ./applications
    ./desktop-environment
    ./theme
    ./multimedia
    ./mimetypes
    ./fonts
    ./work
    ./catppuccin.nix
  ];

  nixpkgs.overlays = [
    (_final: prev: {
      lib = prev.lib.extend (
        _self: _super: {
          dotfiles = {
            # Add lib functions here.
          };
        }
      );
    })
  ];
}
