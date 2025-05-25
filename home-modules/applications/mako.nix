{ ... }:
{
  services.mako = {
    enable = true;
    settings = {
      border-size = 0;
      default-timeout = 1500;
      #ignoreTimeout = true;
      #width = 300;
      #height = 100;
      #font = "monospace 10";
    };
  }; # TODO
  catppuccin.mako.enable = true;
}
