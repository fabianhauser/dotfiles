{ pkgs, lib, ... }:

let
  inherit (pkgs) writeShellApplication kitty libnotify;
  inherit (lib) getExe;
in
{

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    memory.text = ''
      - If you're not sure about something, or there are multiple options, ask me!
      - Always use project formatters, before running tests and before commiting.
      - Always remember to check that your change builds, and tests pass.
        Avoid assumptions, you take full responsibility (or ask me what you should do).
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
          "Bash(nix log *)"
          "Bash(nix fmt *)"
          "Bash(nix flake check *)"
          "Bash(nix build *)"
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
        command = ''
          input=$(cat); echo "[$(echo "$input" | jq -r '.model.display_name')] 📁 $(basename "$(echo "$input" | jq -r '.workspace.current_dir')")"
        '';
        padding = 0;
        type = "command";
      };
    };

  };
}
