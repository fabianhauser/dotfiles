{
  nixConfig = {
    extra-substituters = "https://cache.garnix.io";
    extra-trusted-public-keys = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
  };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";
    fcc-unlock = {
      url = "github:fabianhauser/fcc-unlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    emanote = {
      url = "github:srid/emanote";
      inputs = {
        emanote-template.follows = "";
        nixpkgs.follows = "nixpkgs";
      };
    };

    private.url = "git+file:./private";
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = map (name: inputs.${name}.flakeModule) [
        "treefmt-nix"
        "ez-configs"
      ];
      systems = [
        "x86_64-linux"
      ];
      perSystem =
        { pkgs, lib, ... }:
        {
          treefmt = {
            programs = {
              nixfmt.enable = true;
              deadnix.enable = true;
            };
            settings.global.excludes = [ "*.jpg" ];
          };

          devShells.default = pkgs.mkShell {
            name = "nix-config-default-shell";
            packages = lib.attrValues {
              inherit (pkgs)
                nixos-rebuild
                nixos-facter
                attic-client
                sops
                ssh-to-age
                nixd
                ;
            };
          };

        };
      ezConfigs = {
        root = ./.;
        globalArgs = { inherit inputs; };
        nixos.hosts =
          with nixpkgs.lib;
          genAttrs [ "speer" "ochsenchopf" ] (const {
            userHomeModules = [ "fhauser" ];
          });
      };
    };
}
