{
  config,
  pkgs,
  ...
}:

{

  imports = [
    ./anki.nix
    ./catppuccin.nix
    ./codium.nix
    ./emanote.nix
    ./evolution.nix
    ./firefox.nix
    ./gammastep.nix
    ./git.nix
    ./gpg.nix
    ./kanshi.nix
    ./kitty.nix
    ./mako.nix
    ./psql.nix
    ./scripts.nix
    ./shell.nix
    ./ssh.nix
    ./sway.nix
    ./swaylock.nix
    ./vim.nix
    ./waybar.nix
    ./webapps.nix
    ./zed-editor.nix
  ];

  services = {
    network-manager-applet.enable = true;
    nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
    pasystray.enable = true;
    blueman-applet.enable = true;
  };

  home = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    packages =
      with pkgs;
      [
        # Networking
        transmission_4 # GUI Tools, maybe extract...
      ]
      ++ [
        # Desktop Environment Applications
        google-chrome
        chromium
        nextcloud-client
        xfce.thunar
        xfce.thunar-archive-plugin
        xfce.xfce4-appfinder
        xfce.mousepad
        bitwarden-desktop
        pinentry-rofi # Required by gnupg
      ]
      ++ [
        # office
        libreoffice-fresh # TODO: Dictionaries, nixos/nixpkgs#14430
        tectonic
        pandoc
        texliveSmall
        simple-scan
        gnome-online-accounts
        gnome-control-center
        todoist-electron
        obsidian
        smile
        qdigidoc
      ]
      ++ [
        # Communication
        jitsi-meet-electron
        teams-for-linux
        rdesktop
        # davinci-resolve # TODO: This package is big. Maybe write a wrapper around nix run?
      ]
      ++ [
        # Development
        virt-manager
        modemmanager # TODO: makes sense here?
        modem-manager-gui
        tealdeer
        llm
      ];

    #TODO: Write module
    activation.statefulConfigSymlinks = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      set -eo pipefail

      STATEFUL_ROOT="$HOME/.stateful"
      if [ ! -d "$STATEFUL_ROOT" ]; then
         $DRY_RUN_CMD mkdir "$STATEFUL_ROOT"
      fi

      STATEFUL_CONFS=(
        ".config/spotify"
        ".mozilla"
        ".password-store"
      )
      for STATEFUL_CONF in ''${STATEFUL_CONFS[@]}; do
        if [ -e "$STATEFUL_CONF" ] && [ ! -h "$STATEFUL_CONF" ]; then
          echo "File $STATEFUL_CONF already exists, exiting!" >&2
          exit 1
        fi

        if [ -h "$STATEFUL_CONF" ]; then
          $DRY_RUN_CMD rm "$STATEFUL_CONF"
        fi

        STATEFUL_CONF_DIR="$STATEFUL_ROOT/$STATEFUL_CONF"
        $DRY_RUN_CMD mkdir -p "$STATEFUL_CONF_DIR"
        $DRY_RUN_CMD ln -s $VERBOSE_ARG "$STATEFUL_CONF_DIR" "$HOME/$STATEFUL_CONF"
      done
    '';
  };
}
