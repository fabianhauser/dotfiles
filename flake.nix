{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = map (name: inputs.${name}.flakeModule) [
        "treefmt-nix"
        "ez-configs"
      ];
      systems = [
        "x86_64-linux"
      ];
      perSystem =
        { ... }:
        {
          treefmt.programs = {
            nixfmt.enable = true;
            deadnix.enable = true;
          };

        };
      ezConfigs = {
        root = ./.;
        globalArgs = { inherit inputs; };
      };
    };
}
