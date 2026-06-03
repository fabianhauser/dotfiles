{ inputs, ... }:

{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];

  catppuccin = {
    enable = true;
    autoEnable = false;
    flavor = "mocha";
    tty.enable = true;
  };

}
