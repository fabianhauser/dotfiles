{ pkgs, lib, ... }:

let
  inherit (pkgs) writeShellApplication kitty libnotify;
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

      echo "$STATUS"
    '';
  };
in
{

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
    '';

    settings = {
      includeCoAuthoredBy = false;
      defaultMode = "plan";

      permissions = {
        allow = [
          "Bash(nix log:*)"
          "Bash(nix fmt:*)"
          "Bash(nix flake check:*)"
          "Bash(nix build:*)"
        ];
      };

      hooks = {
        Notification = [
          {
            matcher = "permission_prompt|idle_prompt";
            hooks = [
              {
                type = "command";
                command = getExe (writeShellApplication {
                  name = "claude-notification";
                  runtimeInputs = [
                    kitty
                    libnotify
                  ];
                  text = ''
                    INPUT=$(cat)

                    ID=$(echo "$INPUT" | jq -r '.session_id')
                    TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code"')
                    MSG=$(echo "$INPUT" | jq -r '.message // "Needs your attention"')

                    if [ -v KITTY_WINDOW_ID ]; then

                      IS_FOCUSED=$(
                        kitten @ ls | \
                        jq --argjson wid "$KITTY_WINDOW_ID" '[.[].tabs[].windows[] | select(.id == $wid)] | .[0].is_focused'
                      )
                      if [ "$IS_FOCUSED" = 'true' ]; then
                        echo "Window is focused - skipping notification"
                        exit 0
                      fi

                    kitten notify \
                      --icon question \
                      --app-name claude-code \
                      --urgency normal \
                      --type agent \
                      --identifier "$ID" \
                      "$TITLE" \
                      "$MSG"

                    else

                      notify-send \
                        --icon question \
                        --app-name claude-code \
                        --urgency normal \
                        --category agent \
                        --replace-id "$ID" \
                        "$TITLE" \
                        "$MSG"
                    fi
                  '';
                });
              }
            ];
          }
        ];
      };

      statusLine = {
        command = getExe statuslineScript;
        padding = 0;
        type = "command";
      };
    };

  };
}
