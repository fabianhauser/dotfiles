{ pkgs, config, ... }:
{
  home.packages = [ config.services.tldr-update.package ];
  services.tldr-update = {
    enable = true;
    package = pkgs.tealdeer;
  };
  programs = {
    bash = {
      enable = true;
      historyIgnore = [
        "ls"
        "cd"
        "exit"
        "j"
      ];
      shellAliases = {
        # Sane defaults
        l = "ls --color -lah";
        cp = "cp --reflink=auto";
        pwgen = "pwgen -c -n -s -N 30";
        bc = "bc --mathlib";
        cal = "cal -m";
        curl = "curl -L";
        ack = "rg";

        # Git helpers
        git-fetch-pr = "git config --add remote.origin.fetch '+refs/pull/*/head:refs/remotes/origin/pr/*'";
        git-config-fetchall = ''git config --add remote.origin.fetch "+refs/pull/*/head:refs/remotes/origin/pr/*"'';

        git-enable-signing = "git config commit.gpgsign true && git config tag.gpgsign true";
        # Common Typos
        gits = "git s";
      };
      initExtra = ''
        function o(){
          xdg-open "$*" >/dev/null 2>&1 &
        }
      '';
      shellOptions = [
        "autocd"
        "checkjobs"
        "dotglob"
        "globstar"
        "histappend"
      ];
      sessionVariables = {
        #TODO: Some of these should be migrated to the according application.
        GPG_TTY = "$(tty)";
        PGDATABASE = "postgres";
        NIXOS_OZONE_WL = "1";
      };
    };

    autojump = {
      enable = true;
      enableBashIntegration = true;
    };
    powerline-go = {
      enable = true;
      settings = {
        hostname-only-if-ssh = true;
        numeric-exit-codes = true;
        colorize-hostname = true;
        cwd-max-depth = 4;
        cwd-max-dir-size = 48;
        cwd-mode = "semifancy";
        modules = "ssh,host,root,cwd,perms,dotenv,venv,nix-shell,git,jobs";
      };
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
