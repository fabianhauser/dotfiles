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
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.i3ipc ]);
  workspaceBgScript = pkgs.writeScript "sway-workspace-bg" ''
    #!${pythonEnv}/bin/python3
    import i3ipc, subprocess, threading, time, signal, sys

    COLORS = {
        "0": "${colors.base08}",
        "1": "${colors.base09}",
        "2": "${colors.base0A}",
        "3": "${colors.base0B}",
        "4": "${colors.base0C}",
        "5": "${colors.base0D}",
        "6": "${colors.base0E}",
        "7": "${colors.base0F}",
        "8": "${colors.base07}",
        "9": "${colors.base06}",
    }

    bg_proc = None

    def set_bg(name):
        global bg_proc
        color = COLORS.get(name, "${colors.base00}")
        old_proc = bg_proc
        bg_proc = subprocess.Popen(["${pkgs.swaybg}/bin/swaybg", "-c", color])
        if old_proc is not None:
            def kill_old():
                time.sleep(0.05)
                old_proc.terminate()
                old_proc.wait(timeout=1)
            threading.Thread(target=kill_old, daemon=True).start()

    def cleanup(sig, frame):
        if bg_proc is not None:
            bg_proc.terminate()
        sys.exit(0)

    signal.signal(signal.SIGTERM, cleanup)
    signal.signal(signal.SIGINT, cleanup)

    def on_focus(ipc, event):
        set_bg(event.current.name)

    ipc = i3ipc.Connection()
    focused = next((w for w in ipc.get_workspaces() if w.focused), None)
    if focused:
        set_bg(focused.name)
    ipc.on("workspace::focus", on_focus)
    ipc.main()
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
            };
          in
          mkOptionDefault {
            "${mod}+Shift+d" = "exec ${getExe pkgs.rofimoji} --action clipboard --selector fuzzel";
            "${mod}+x" = "move workspace to output right";
            "${mod}+y" = "move workspace to output left";

            "${mod}+${ws."0"}" = "workspace number 0";

            "${mod}+Shift+${ws."0"}" = "move container to workspace number 0";

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

    systemd.user.services.sway-workspace-bg = {
      Unit = {
        Description = "Per-workspace sway background colors";
        After = [ "sway-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${workspaceBgScript}";
        Restart = "on-failure";
        RestartSec = "1";
      };
      Install.WantedBy = [ "sway-session.target" ];
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
