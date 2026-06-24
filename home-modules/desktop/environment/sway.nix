{
  pkgs,
  lib,
  config,
  osConfig,
  dotfilesSwaySpaces,
  ...
}:
let
  inherit (lib)
    mkIf
    getExe
    ;
  cfg = config.dotfiles.desktop;
  colors = config.lib.stylix.colors.withHashtag;
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.i3ipc ]);
  spacesCli = "${dotfilesSwaySpaces.wrapper}/bin/dotfiles-sway-spaces";
  backgroundsDir = "${config.home.homeDirectory}/cloud/pictures/backgrounds";
  workspaceBgScript = pkgs.writeScript "sway-workspace-bg" ''
    #!${pythonEnv}/bin/python3
    import i3ipc, re, os, glob, json, subprocess, threading, time, signal, sys

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

    BACKGROUNDS_DIR = "${backgroundsDir}"
    CACHE_DIR = os.path.join(
        os.environ.get("XDG_CACHE_HOME") or os.path.expanduser("~/.cache"),
        "dotfiles-sway-backgrounds",
    )
    MAGICK = "${pkgs.imagemagick}/bin/magick"
    XXHSUM = "${pkgs.xxhash}/bin/xxhsum"
    SWAYBG = "${pkgs.swaybg}/bin/swaybg"
    SWAYMSG = "${pkgs.sway}/bin/swaymsg"

    bg_proc = None
    current_project = None

    def space_project(name):
        m = re.match(r'^\d+', name)
        if not m:
            return None
        digits = m.group(0)[:2]
        padded = f"{int(digits):02}"
        return padded[0], padded[1]

    def screen_size():
        outputs = json.loads(subprocess.check_output([SWAYMSG, "-t", "get_outputs", "-r"]))
        edges = [
            max(o["current_mode"]["width"], o["current_mode"]["height"])
            for o in outputs
            if o.get("active") and o.get("current_mode")
        ]
        return max(edges) if edges else None

    def source_image(project):
        matches = sorted(glob.glob(os.path.join(BACKGROUNDS_DIR, project + ".*")))
        return matches[0] if matches else None

    def cached_image(src, size):
        digest = subprocess.check_output([XXHSUM, src]).split()[0].decode()
        os.makedirs(CACHE_DIR, exist_ok=True)
        cache = os.path.join(CACHE_DIR, f"{digest}-{size}.jpg")
        if not os.path.exists(cache):
            tmp = f"{cache}.tmp"
            subprocess.run(
                [MAGICK, src, "-auto-orient", "-resize", f"{size}x{size}>",
                 "-quality", "85", tmp],
                check=True,
            )
            os.replace(tmp, cache)
        return cache

    def swaybg_cmd(project):
        src = source_image(project)
        size = screen_size()
        if src and size:
            try:
                return [SWAYBG, "-i", cached_image(src, size), "-m", "fill"]
            except (subprocess.CalledProcessError, OSError):
                pass
        return [SWAYBG, "-c", COLORS.get(project, "${colors.base00}")]

    def set_bg(project):
        global bg_proc
        old_proc = bg_proc
        bg_proc = subprocess.Popen(swaybg_cmd(project))
        if old_proc is not None:
            def kill_old():
                time.sleep(0.5)
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
        global current_project
        sp = space_project(event.current.name)
        if sp is not None:
            current_project = sp[1]
            set_bg(current_project)

    def on_output(ipc, event):
        if current_project is not None:
            set_bg(current_project)

    ipc = i3ipc.Connection()
    focused = next((w for w in ipc.get_workspaces() if w.focused), None)
    if focused:
        sp = space_project(focused.name)
        if sp is not None:
            current_project = sp[1]
            set_bg(current_project)
    ipc.on("workspace::focus", on_focus)
    ipc.on("output", on_output)
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

        startup = [
          {
            command = "${spacesCli} init 0";
            always = true;
          }
        ];

        keybindings =
          let
            mod = config.wayland.windowManager.sway.config.modifier;
            playerctl = getExe pkgs.playerctl;
            wpctl = "${pkgs.wireplumber}/bin/wpctl";
            brightnessctl = getExe pkgs.brightnessctl;
            # space (first digit, swaysome group): number row, Mod+N / Mod+Shift+N
            # project (second digit, swaysome workspace): function row, Mod+F{N} / Mod+Shift+F{N}
            spaceKeys = {
              "0" = [
                "grave"
                "0"
              ];
              "1" = [ "1" ];
              "2" = [ "2" ];
              "3" = [ "3" ];
              "4" = [ "4" ];
              "5" = [ "5" ];
              "6" = [ "6" ];
              "7" = [ "7" ];
              "8" = [ "8" ];
              "9" = [ "9" ];
            };
            projectKeys = {
              "0" = [
                "F10"
                "Escape"
              ];
              "1" = [ "F1" ];
              "2" = [ "F2" ];
              "3" = [ "F3" ];
              "4" = [ "F4" ];
              "5" = [ "F5" ];
              "6" = [ "F6" ];
              "7" = [ "F7" ];
              "8" = [ "F8" ];
              "9" = [ "F9" ];
            };
            spaceBindings = lib.concatMapAttrs (
              n: keys:
              lib.foldl' (
                acc: key:
                acc
                // {
                  "${mod}+${key}" = "exec ${spacesCli} focus-space ${n}";
                  "${mod}+Shift+${key}" = "exec ${spacesCli} move-to-space ${n}";
                }
              ) { } keys
            ) spaceKeys;
            projectBindings = lib.concatMapAttrs (
              n: keys:
              lib.foldl' (
                acc: key:
                acc
                // {
                  "${mod}+${key}" = "exec ${spacesCli} focus-project ${n}";
                  "${mod}+Shift+${key}" = "exec ${spacesCli} move-to-project ${n}";
                }
              ) { } keys
            ) projectKeys;
          in
          {
            "${mod}+Return" = "exec ${getExe pkgs.kitty}";
            "${mod}+Shift+q" = "kill";
            "${mod}+d" = "exec ${getExe bemenuLauncher}";
            "${mod}+h" = "focus left";
            "${mod}+j" = "focus down";
            "${mod}+k" = "focus up";
            "${mod}+l" = "focus right";
            "${mod}+Left" = "focus left";
            "${mod}+Down" = "focus down";
            "${mod}+Up" = "focus up";
            "${mod}+Right" = "focus right";
            "${mod}+Shift+h" = "move left";
            "${mod}+Shift+j" = "move down";
            "${mod}+Shift+k" = "move up";
            "${mod}+Shift+l" = "move right";
            "${mod}+Shift+Left" = "move left";
            "${mod}+Shift+Down" = "move down";
            "${mod}+Shift+Up" = "move up";
            "${mod}+Shift+Right" = "move right";
            "${mod}+b" = "splith";
            "${mod}+v" = "splitv";
            "${mod}+f" = "fullscreen toggle";
            "${mod}+a" = "focus parent";
            "${mod}+s" = "layout stacking";
            "${mod}+w" = "layout tabbed";
            "${mod}+e" = "layout toggle split";
            "${mod}+Shift+space" = "floating toggle";
            "${mod}+space" = "focus mode_toggle";
            "${mod}+Shift+minus" = "move scratchpad";
            "${mod}+minus" = "scratchpad show";
            "${mod}+Shift+c" = "reload";
            "${mod}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -b 'Yes, exit sway' 'swaymsg exit'";
            "${mod}+r" = "mode resize";

            "${mod}+Shift+d" = "exec ${getExe pkgs.rofimoji} --action clipboard --selector fuzzel";
            "${mod}+Ctrl+n" = "exec ${spacesCli} set-name";
            "${mod}+x" = "move workspace to output right";
            "${mod}+y" = "move workspace to output left";

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
            XF86MonBrightnessUp = "exec ${brightnessctl} set +10%";
            XF86MonBrightnessDown = "exec ${brightnessctl} set 5%-";

            # screenshot
            Print = "exec ${getExe pkgs.sway-contrib.grimshot} copy area";
          }
          // spaceBindings
          // projectBindings;

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
        Description = "Per-project sway background images";
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
