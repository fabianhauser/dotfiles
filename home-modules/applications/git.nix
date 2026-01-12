{
  pkgs,
  inputs,
  config,
  ...
}:
let
  inherit (pkgs.lib)
    mkOption
    attrValues
    concatLists
    pipe
    mapAttrs
    ;
  inherit (pkgs.lib.types)
    submodule
    listOf
    attrsOf
    str
    attrs
    ;
in
{

  imports = [
    inputs.private.homeModules.git
  ];

  options.dotfiles.git.profiles = mkOption {
    description = "Configuration profiles applied to specific directories";
    type = attrsOf (
      submodule (
        { ... }:
        {
          options = {
            directories = mkOption {
              type = listOf str;
            };
            settings = mkOption {
              type = attrs;
              default = { };
            };
          };
        }
      )
    );
    default = { };
  };

  config = {
    dotfiles = {
      git = {
        profiles.private = {
          directories = [
            "~/private/"
            "~/projects/"
            "~/.password-store/"
            "~/.stateful/"
          ];
          settings.user = {
            signingkey = "0x8A52A140BEBF7D2C";
            email = "fabian@fh2.ch";
            name = "Fabian Hauser";
          };

        };
      };
    };
    home.packages = with pkgs; [
      git-absorb
      git-trim
    ];
    programs.git = {
      enable = true;
      package = pkgs.gitFull;
      #delta = {
      #  enable = true;
      #  catppuccin.enable = true;
      #  options = {
      #    side-by-side = "true";

      #    line-numbers = "true";
      #    line-numbers-minus-style = "#444444";
      #    line-numbers-zero-style = "#444444";
      #    line-numbers-plus-style = "#444444";
      #    line-numbers-left-format = "{nm:>4}┊";
      #    line-numbers-right-format = "{np:>4}│";
      #    line-numbers-left-style = "blue";
      #    line-numbers-right-style = "blue";
      #  };
      #};
      settings = {
        init.defaultBranch = "main";
        core = {
          packedGitWindowSize = "16m";
          packedGitLimit = "64m";
        };
        pack = {
          windowMemory = "64m";
          packSizeLimit = "64m";
          thread = "1";
          deltaCacheSize = "1m";
        };
        alias = {
          s = "status --short --branch";
          a = "add --patch";
          c = "commit --message";
          l = "log --color --graph --pretty=format:'%Cred%h%Creset - %C(bold)%s%Creset%C(yellow)%d%Creset %C(green)%an%Creset %C(cyan)%cr%Creset (S: %G?)' --abbrev-commit";
          d = "diff";

          fup = "commit --fixup";
          fuprebase = "rebase --interactive --autosquash";

          ignore = "update-index --skip-worktree";
          unignore = "update-index --no-skip-worktree";
          ignored = ''!git ls-files -v | grep "^S"'';
        };
        color = {
          branch = "auto";
          diff = "auto";
          status = "auto";
        };
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        pull.rebase = "true";
        branch.autosetuprebase = "always";
        log.follow = true;
        rerere.enabled = true;
        fetch.recurseSubmodules = "on-demand";
        credential.helper = [
          "libsecret"
          "cache --timeout 21600"
        ];
      };
      ignores = [
        "*~"
        "*.swp"
        ".direnv/"
      ];
      lfs.enable = true;
      includes =
        let
          mkConfig =
            name:
            { settings, directories }:
            map (directory: {
              condition = "gitdir:${directory}";
              contentSuffix = name;
              contents = settings;
            }) directories;
        in
        pipe config.dotfiles.git.profiles [
          (mapAttrs mkConfig)
          attrValues
          concatLists
        ];
    };
    programs.git-credential-oauth.enable = true;
  };
}
