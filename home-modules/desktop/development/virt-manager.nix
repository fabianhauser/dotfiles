{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.dotfiles.development.enable {
    home.packages = with pkgs; [
      virt-manager
      android-tools
    ];
  };
}
