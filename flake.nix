{
  nixConfig = {
    extra-substituters = "https://attic.qo.is/dotfiles https://cache.garnix.io";
    extra-trusted-public-keys = "dotfiles:KpLi0qe5O5rb8E8N8vntZWBDqFwG3Ksx4AFGizYCLoU= cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
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
    inputs@{
      flake-parts,
      nixpkgs,
      self,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = map (name: inputs.${name}.flakeModule) [
        "treefmt-nix"
        "ez-configs"
      ];
      systems = [
        "x86_64-linux"
      ];
      perSystem =
        {
          pkgs,
          lib,
          self',
          ...
        }:
        {
          treefmt = {
            programs = {
              nixfmt.enable = true;
              deadnix.enable = true;
              jsonfmt.enable = true;
              yamlfmt.enable = true;
              mdformat.enable = true;
            };
            settings.global.excludes = [ "*.jpg" ];
          };

          checks =
            with lib;
            concatMapAttrs
              (typeName: concatMapAttrs (objectName: value: { "${typeName}-${objectName}" = value; }))
              {
                inherit (self') devShells;
                nixosConfigurations = mapAttrs (
                  _name: value: value.config.system.build.toplevel
                ) self.nixosConfigurations;
              };

          devShells.default = pkgs.mkShell {
            name = "nix-config-default-shell";
            packages = lib.attrValues {
              inherit (pkgs)
                nixos-rebuild
                nixos-facter
                nix-fast-build
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
