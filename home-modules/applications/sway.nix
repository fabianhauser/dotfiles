{
  pkgs,
  lib,
  config,
  ...
}:
let
  adhereTheSwayTarget = {
    Install.WantedBy = lib.mkForce [ "sway-session.target" ];
    Unit.PartOf = lib.mkForce [ "sway-session.target" ];
  };
  # TODO: active screen with -m $active_screen
  bemenuLauncher = pkgs.writeScriptBin "bemenuLauncher" ''
    #!${pkgs.stdenv.shell}
    #active_screen=$(swaymsg -r -t get_outputs | \
    #  ${pkgs.jq}/bin/jq '. [] | select (.focused == true) | .name | split ("-") | last')
    ${pkgs.dmenu}/bin/dmenu_path | \
      ${pkgs.bemenu}/bin/bemenu --list 20 --ignorecase --prompt 'Start: ' | \
      xargs swaymsg exec --
  '';
in
rec {
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
          xkb_layout = "ch,de";
          xkb_options = "eurosign:e";
        };
        "*" = {
          xkb_numlock = "enable";
        };
      };
      terminal = "${pkgs.kitty}/bin/kitty";
      menu = "${bemenuLauncher}/bin/bemenuLauncher";
      gaps.inner = 8;
      modifier = "Mod4";
      window.border = 0;
      #colors.focused.border = "#323232";

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
          mod = wayland.windowManager.sway.config.modifier;
          playerctl = "${pkgs.playerctl}/bin/playerctl";
          wpctl = "${pkgs.wireplumber}/bin/wpctl";
          light = "${pkgs.light}/bin/light";
        in
        lib.mkOptionDefault {
          "${mod}+p" = "exec passbemenu";
          "${mod}+Shift+d" = "exec ${pkgs.rofimoji}/bin/rofimoji --action clipboard --selector fuzzel";
          "${mod}+x" = "move workspace to output right";
          "${mod}+y" = "move workspace to output left";

          "${mod}+section" = "workspace 0";
          "${mod}+0" = "workspace 10";
          "${mod}+apostrophe" = "workspace 11";
          "${mod}+dead_circumflex" = "workspace 12";
          "${mod}+dead_diaeresis" = "workspace 13";
          "${mod}+dollar" = "workspace 14";

          "${mod}+Shift+section" = "move container to workspace 0";
          "${mod}+Shift+0" = "move container to workspace 10";
          "${mod}+Shift+apostrophe" = "move container to workspace 11";
          "${mod}+Shift+dead_circumflex" = "move container to workspace 12";
          "${mod}+Shift+dead_diaeresis" = "move container to workspace 13";
          "${mod}+Shift+dollar" = "move container to workspace 14";

          "Ctrl+mod1+l" = "exec ${pkgs.systemd}/bin/loginctl lock-session";
          "Ctrl+mod1+Shift+L" = "exec ${pkgs.systemd}/bin/systemctl suspend";

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
          XF86MonBrightnessUp = "exec ${light} -A 10";
          XF86MonBrightnessDown = "exec ${light} -U 5";

          # screenshot
          Print = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
        };
    };
    extraConfig = ''
      # Disable the laptop screen when the lid is closed.
      bindswitch --reload lid:on output eDP-1 disable
      bindswitch --reload lid:off output eDP-1 enable

      # Workaround for https://bugs.chromium.org/p/chromium/issues/detail?id=1338554
      for_window [app_id="^chrome-.*-.*$"] shortcuts_inhibitor disable

      output "*" bg ${./mountain.jpg} fill
    '';
  };
  catppuccin.sway.enable = true;

  systemd.user.services.network-manager-applet = adhereTheSwayTarget;
  systemd.user.services.nextcloud-client = adhereTheSwayTarget // {
    # For trayicon to work:
    Unit.After = lib.mkForce [ "waybar.service" ];
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
      Environment = lib.mkForce "PATH=${config.home.profileDirectory}/bin XDG_CURRENT_DESKTOP=Unity";
    };
  };
  systemd.user.services.pasystray = adhereTheSwayTarget;

  gtk = {
    iconTheme = {
      # package = pkgs.gnome-icon-theme;
      # name = "gnome";
      package = pkgs.hicolor_icon_theme;
      name = "hicolor";
    };
    gtk3.extraConfig.gtk-menu-images = true;
  };
  catppuccin.gtk.enable = true;

  dconf.settings = {
    "org/gnome/desktop/interface".menus-have-icons = true;
  };
}
