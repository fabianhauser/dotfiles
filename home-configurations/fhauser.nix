{
  osConfig,
  ...
}:
{
  home =
    let
      username = "fhauser";
    in
    {
      inherit username;
      inherit (osConfig.system) stateVersion;
      homeDirectory = osConfig.users.users.${username}.home;
    };

  dotfiles.desktop.enable = true;
  dotfiles.desktop.security.enable = true;
  dotfiles.development.enable = true;
}
