{ inputs, ... }:

{

  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    backupFileExtension = ".hm-bak";
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
