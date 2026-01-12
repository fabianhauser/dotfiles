{
  ...
}:
{
  imports = [
    ./applications
    ./theme
    ./multimedia
    ./mimetypes
    ./fonts
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
