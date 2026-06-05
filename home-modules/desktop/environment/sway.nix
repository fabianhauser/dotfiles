{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOptionDefault
    getExe
    ;
  cfg = config.dotfiles.desktop;
  colors = config.lib.stylix.colors.withHashtag;
  workspaceBgScript = pkgs.writeShellScript "sway-workspace-bg" ''
    LOCKFILE=/tmp/sway-workspace-bg.lock
    if [ -f "$LOCKFILE" ]; then
      kill "$(cat "$LOCKFILE")" 2>/dev/null || true
    fi
    echo $$ > "$LOCKFILE"
    trap 'rm -f "$LOCKFILE"' EXIT

    set_bg() {
      case "$1" in
        0) ${pkgs.sway}/bin/swaymsg "output '*' bg ${colors.base08} solid_color" ;;
        1) ${pkgs.sway}/bin/swaymsg "output '*' bg ${colors.base09} solid_color" ;;
        2) ${pkgs.sway}/bin/swaymsg "output '*' bg ${colors.base0A} solid_color" ;;
        3) ${pkgs.sway}/bin/swaymsg "output '*' bg ${colors.base0B} solid_color" ;;
        4) ${pkgs.sway}/bin/swaymsg "output '*' bg ${colors.base0C} solid_color" ;;
        5) ${pkgs.sway}/bin/swaymsg "output '*' bg ${colors.base0D} solid_color" ;;
        6) ${pkgs.sway}/bin/swaymsg "output '*' bg ${colors.base0E} solid_color" ;;
        7) ${pkgs.sway}/bin/swaymsg "output '*' bg ${colors.base0F} solid_color" ;;
        8) ${pkgs.sway}/bin/swaymsg "output '*' bg ${colors.base07} solid_color" ;;
        9) ${pkgs.sway}/bin/swaymsg "output '*' bg ${colors.base06} solid_color" ;;
        *) ${pkgs.sway}/bin/swaymsg "output '*' bg ${colors.base00} solid_color" ;;
      esac
    }

    current=$(${pkgs.sway}/bin/swaymsg -t get_workspaces | ${pkgs.jq}/bin/jq -r '.[] | select(.focused) | .name')
    set_bg "$current"

    ${pkgs.sway}/bin/swaymsg -t subscribe '["workspace"]' | while IFS= read -r line; do
      ws=$(printf '%s' "$line" | ${pkgs.jq}/bin/jq -r 'select(.change == "focus") | .current.name')
      [ -n "$ws" ] && set_bg "$ws"
    done
  '';
  # TODO: active screen with -m $active_screen
  bemenuLauncher = pkgs.writeScriptBin "bemenuLauncher" ''
    #!${pkgs.stdenv.shell}
    #active_screen=$(swaymsg -r -t get_outputs | \
    #  ${getExe pkgs.jq} '. [] | select (.focused == true) | .name | split ("-") | last')
    ${pkgs.dmenu}/bin/dmenu_path | \
      ${getExe pkgs.bemenu} --list 20 --ignorecase --prompt 'Start: ' | \
      xargs swaymsg exec --
  '';
in
{
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      sway-contrib.grimshot
      wl-clipboard
      libappindicator
      adwaita-icon-theme
      gnome-icon-theme
      hicolor-icon-theme # TODO: Move these requirements?
      fuzzel # Required for rofimoji
    ];

    xsession.preferStatusNotifierItems = true;

    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      xwayland = true;
      wrapperFeatures = {
        gtk = true;
      };
      extraSessionCommands = ''
        #export XDG_CURRENT_DESKTOP=Unity
        export XDG_CURRENT_DESKTOP=sway
        export XDG_SESSION_TYPE="wayland"
        export _JAVA_AWT_WM_NONREPARENTING=1
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # TODO: QTpie
        export WLR_DRM_NO_MODIFIERS=1
        export WLR_NO_HARDWARE_CURSORS=1
      '';
      config = {
        input = {
          "type:keyboard" = {
            xkb_layout = "us(altgr-intl)";
          };
          "*" = {
            xkb_numlock = "enable";
          };
        };
        terminal = getExe pkgs.kitty;
        menu = getExe bemenuLauncher;
        gaps.inner = 8;
        modifier = "Mod4";

        #TODO: Workspace Programm assignment: Not working properly
        assigns = {
          "10" = [ { app_id = "^firefox$"; } ];
          "11" = [ { app_id = "^(claws-mail|thunderbird|evolution)$"; } ];
          "12" = [
            {
              class = "^Chromium-browser$";
              instance = "^web.threema.ch";
            }
          ];
          "13" = [ { class = "^Spotify$"; } ];
        };

        keybindings =
          let
            mod = config.wayland.windowManager.sway.config.modifier;
            playerctl = getExe pkgs.playerctl;
            wpctl = "${pkgs.wireplumber}/bin/wpctl";
            light = getExe pkgs.brightnessctl;
            ws = {
              "0" = "grave";
              "10" = "0";
              "11" = "minus";
              "12" = "equal";
              "13" = "bracketright";
              "14" = "backslash";
            };
          in
          mkOptionDefault {
            "${mod}+Shift+d" = "exec ${getExe pkgs.rofimoji} --action clipboard --selector fuzzel";
            "${mod}+x" = "move workspace to output right";
            "${mod}+y" = "move workspace to output left";

            "${mod}+${ws."0"}" = "workspace 0";
            "${mod}+${ws."10"}" = "workspace 10";
            "${mod}+${ws."11"}" = "workspace 11";
            "${mod}+${ws."12"}" = "workspace 12";
            "${mod}+${ws."13"}" = "workspace 13";
            "${mod}+${ws."14"}" = "workspace 14";

            "${mod}+Shift+${ws."0"}" = "move container to workspace 0";
            "${mod}+Shift+${ws."10"}" = "move container to workspace 10";
            "${mod}+Shift+${ws."11"}" = "move container to workspace 11";
            "${mod}+Shift+${ws."12"}" = "move container to workspace 12";
            "${mod}+Shift+${ws."13"}" = "move container to workspace 13";
            "${mod}+Shift+${ws."14"}" = "move container to workspace 14";

            "Ctrl+mod1+l" = "exec ${osConfig.systemd.package or pkgs.systemd}/bin/loginctl lock-session";
            "Ctrl+mod1+Shift+L" = "exec ${osConfig.systemd.package or pkgs.systemd}/bin/systemctl suspend";

            # pulse audio volume control
            XF86AudioLowerVolume = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 3%-";
            XF86AudioRaiseVolume = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 3%+";
            XF86AudioMute = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
            XF86AudioMicMute = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

            # Spotify control
            XF86AudioPause = "exec ${playerctl} play-pause";
            XF86AudioPlay = "exec ${playerctl} play-pause";
            XF86AudioNext = "exec ${playerctl} next";
            XF86AudioPrev = "exec ${playerctl} previous";

            # screen brightness
            XF86MonBrightnessUp = "exec ${light} +10%";
            XF86MonBrightnessDown = "exec ${light} 5%-";

            # screenshot
            Print = "exec ${getExe pkgs.sway-contrib.grimshot} copy area";
          };

        startup = [
          {
            command = "${workspaceBgScript}";
            always = true;
          }
        ];
      };
      extraConfig = ''
        # Disable the laptop screen when the lid is closed.
        bindswitch --reload lid:on output eDP-1 disable
        bindswitch --reload lid:off output eDP-1 enable

        # Workaround for https://bugs.chromium.org/p/chromium/issues/detail?id=1338554
        for_window [app_id="^chrome-.*-.*$"] shortcuts_inhibitor disable

        default_border pixel 0
        default_floating_border pixel 0
      '';
    };

    gtk = {
      iconTheme = {
        # package = pkgs.gnome-icon-theme;
        # name = "gnome";
        package = pkgs.hicolor-icon-theme;
        name = "hicolor";
      };
      gtk3.extraConfig.gtk-menu-images = true;
    };

    dconf.settings = {
      "org/gnome/desktop/interface".menus-have-icons = true;
    };
  };
}
