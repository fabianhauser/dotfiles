{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        ForwardAgent = false;
      };
      "*.backplane.net.qo.is" = {
        ProxyJump = "fhauser@lindberg.riedbach-ext.net.qo.is";
      };
    };
  };
}
