{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./claude-code
  ];

  options.dotfiles.development.enable = lib.mkEnableOption "development tools";

  config = lib.mkIf config.dotfiles.development.enable {
    home.packages = with pkgs; [
      forgejo-cli
    ];

    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
      settings = {
        git_protocol = "https";
        aliases = {
          l = "pr list";
          pc = "pr checkout";
          pv = "pr view";
          r-approve = "pr review --approve";

          c = "pr create";
          r-request = "pr comment --body '/request-review'";
        };
      };
    };

    programs.opencode = {
      enable = true;
      extraPackages = [ pkgs.opencode-claude-auth ];
    };

    home.file.".psqlrc".text = ''
      \set QUIET 1

      \pset linestyle unicode
      \pset border 2

      \set null [null]
      \set COMP_KEYWORD_CASE upper
      \set ON_ERROR_ROLLBACK interactive
      \set PROMPT1 '%[%033[1m%]%M/%/%R%[%033[0m%]%# '
      \set PROMPT2 ''''
      \set VERBOSITY verbose
      \timing
      \x auto

      \unset QUIET
      \conninfo
    '';
  };
}
