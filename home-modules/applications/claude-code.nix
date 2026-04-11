{ pkgs, lib, ... }:

let
  inherit (pkgs) writeShellApplication kitty;
  inherit (lib) getExe;
in
{

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
    memory.text = ''
      - If you're not sure about something, just ask :)
      - Always remember to check that your change builds, and tests work, avoid assumptions, you take full responsibility (or ask me what you should do).
      - Always use project formatters, latest before commiting.
      - Follow best practices, like single responsibility principle etc.
      - Think thoroughly about architecture and software design - you're a seasoned software architect and engineer.
      - Commit to Git frequently. Keep commits simple present and concise / shortish.
        In the exceptional case there is more important, non-obvious context, add it in the message after two \n's.
    '';

    settings = {
      includeCoAuthoredBy = false;
      defaultMode = "plan";

      hooks = {
        Notification = [
          {
            matcher = "permission_prompt|idle_prompt";
            hooks = [
              {
                type = "command";
                command = getExe (writeShellApplication {
                  name = "claude-notification";
                  runtimeInputs = [ kitty ];
                  text = ''
                    INPUT=$(cat)

                    if [ ! -v KITTY_WINDOW_ID ]; then
                      echo "Not running in kitty - skipping notification"
                    fi

                    IS_FOCUSED=$(
                      kitten @ ls | \
                      jq --argjson wid "$KITTY_WINDOW_ID" '[.[].tabs[].windows[] | select(.id == $wid)] | .[0].is_focused'
                    )
                    if [ "$IS_FOCUSED" = 'true' ]; then
                      echo "Window is focused - skipping notification"
                      exit 0
                    fi

                    ID=$(echo "$INPUT" | jq -r '.session_id')
                    TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code"')
                    MSG=$(echo "$INPUT" | jq -r '.message // "Needs your attention"')

                    kitten notify \
                      --icon question \
                      --app-name claude-code \
                      --urgency normal \
                      --type agent \
                      --identifier "$ID" \
                      "$TITLE" \
                      "$MSG"
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
