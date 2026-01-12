{
  inputs,
  ...
}:
{
  imports = [ inputs.private.homeConfigurations.work ];
  home = {
    # Mostly defined in private config.
    stateVersion = "25.05";
  };

  targets.genericLinux.enable = true;

  dotfiles.work.enable = true;
}
