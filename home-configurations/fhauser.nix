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
}
