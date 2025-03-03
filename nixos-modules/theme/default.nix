{ inputs, ... }:

{
  imports = [ inputs.catppuccin.nixosModules.catppuccin ];

  catppuccin = {
    flavor = "mocha";
    tty.enable = true;
  };

}
