{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (pkgs) writeShellApplication;
  inherit (lib) getExe;

  statuslineScript = writeShellApplication {
    name = "claude-statusline";
    runtimeInputs = [
      pkgs.jq
      pkgs.gawk
      pkgs.coreutils
    ];
    text = ''
      input=$(cat)

      MODEL=$(echo "$input" | jq -r '.model.display_name')
      DIR=$(basename "$(echo "$input" | jq -r '.workspace.current_dir')")

      FIVE_H_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
      FIVE_H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
      WEEK_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
      CTX_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

      make_bar() {
        local pct=$1
        local width=8
        local filled
        local bar=""
        local i
        filled=$(awk -v p="$pct" -v w="$width" 'BEGIN{printf "%d", p/100*w}')
        filled=''${filled:-0}
        local empty=$((width - filled))
        for ((i=0; i<filled; i++)); do bar="''${bar}█"; done
        for ((i=0; i<empty; i++)); do bar="''${bar}░"; done
        echo "$bar"
      }

      STATUS="[$MODEL] 📁 $DIR"

      if [ -n "$FIVE_H_PCT" ]; then
        BAR=$(make_bar "$FIVE_H_PCT")
        PCT_INT=$(printf '%.0f' "$FIVE_H_PCT")

        RESET_STR=""
        if [ -n "$FIVE_H_RESET" ]; then
          RESET_TIME=$(date -d "@$FIVE_H_RESET" '+%H:%M')
          RESET_STR=" 🔄$RESET_TIME"
        fi

        WEEK_STR=""
        if [ -n "$WEEK_PCT" ]; then
          WEEK_INT=$(printf '%.0f' "$WEEK_PCT")
          WEEK_STR=" 📅''${WEEK_INT}%"
        fi

        STATUS="$STATUS | ⏱️ $BAR ''${PCT_INT}%''${RESET_STR}''${WEEK_STR}"
      fi

      if [ -n "$CTX_PCT" ]; then
        CTX_BAR=$(make_bar "$CTX_PCT")
        CTX_INT=$(printf '%.0f' "$CTX_PCT")
        STATUS="$STATUS | 🔲 $CTX_BAR $CTX_INT%"
      fi

      echo "$STATUS"
    '';
  };
in
{
  config = lib.mkIf config.dotfiles.development.enable {
    programs.claude-code = {
      enable = true;
      enableMcpIntegration = true;
      context = ''
        - If you're not sure about something, or there are multiple options, ask me!
          Avoid assumptions, you take full responsibility (or ask me what you should do).
        - ALWAYS use project formatters, before running tests and before commiting.
        - ALWAYS remember to check that your change builds, and tests pass.
        - Follow best practices around clean code, e.g. single responsibility principle etc.
        - Think thoroughly about architecture and software design - you're a seasoned software architect and engineer.
        - Commit to Git frequently. Keep commits simple present and concise / shortish.
          In the exceptional case there is non-obvious or very complex context, add it in the message after two \n's.
        - Avoid comments in code: the code should be self explanatory through good variable naming,
          and object oriented design or functional design where applicable.
        - Never use `find` or `grep` in `/nix/store` — use `nix eval --raw .#pkg.out` to get exact store paths, then inspect them directly.
        - Use `rg` (ripgrep) instead of `find -exec grep` or `grep -r` for searching files.
      '';

      settings = {
        includeCoAuthoredBy = false;

        # memory
        autoMemoryEnabled = true;
        autoMemoryDirectory = "~/cloud/Notes/claude/memory";

        preferredNotifChannel = "auto"; # Uses kitten automatically

        plansDirectory = "~/cloud/Notes/claude/plans";
        showClearContextOnPlanAccept = true;

        useAutoModeDuringPlan = true;

        disableWorkflows = false;
        workflowKeywordTriggerEnabled = true;

        teammateMode = "auto";

        sandbox = {
          enabled = true;
          filesystem = {
            denyRead = [
              "~/"
              "/var"
              "/etc"
            ];
            allowRead = [
              "/nix/store"
              "~/private/nixos"
            ];
          };
        };
        env = {
          CLAUDE_CODE_ENABLE_AUTO_MODE = 1;
        };

        permissions = {
          defaultMode = "plan";
          allow = [
            "Bash(nix log *)"
            "Bash(nix fmt *)"
            "Bash(nix flake check *)"
            "Bash(nix build *)"
            "Bash(nix eval *)"
            "Bash(nix flake show *)"
            "Bash(nix flake metadata *)"
            "Bash(nix store diff-closures *)"
            "Bash(systemctl --user cat *)"
            "Bash(systemctl --user status *)"
          ];
          skipDangerousModePermissionPrompt = true;
        };

        statusLine = {
          command = getExe statuslineScript;
          padding = 0;
          type = "command";
        };
      };

      skills = {
        nix = ./skills/nix.md;
        git = ./skills/git.md;
      };

    };
  };
}
