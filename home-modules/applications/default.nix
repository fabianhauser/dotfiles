{
  config,
  pkgs,
  ...
}:
{

  imports = [
    ./anki.nix
    ./codium.nix
    ./evolution.nix
    ./firefox.nix
    ./games
    ./gh.nix
    ./git.nix
    ./gpg.nix
    ./kitty.nix
    ./psql.nix
    ./scripts.nix
    ./shell.nix
    ./ssh.nix
    ./vim.nix
    ./webapps.nix
    ./zed-editor.nix
  ];

  services = {
    nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };

  home = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      NIXOS_WAYLAND = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto"; # Only has effect on non-nix applications (i.e. not patched)
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
        thunar
        thunar-archive-plugin
        xfce4-appfinder
        mousepad
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
        smile
        qdigidoc
      ]
      ++ [
        # Communication
        jitsi-meet-electron
        rdesktop
        # davinci-resolve # TODO: This package is big. Maybe write a wrapper around nix run?
      ]
      ++ [
        # Development
        virt-manager
        llm
        android-tools
      ]
      ++ [
        tmux
        bc
        mkpasswd
        rename
        wipe
        pass-wayland
        pwgen
        powertop
      ]
      ++ [
        # File Utilities
        ripgrep
        unzip
        p7zip
        iotop
        tree
      ]
      ++ [
        # Networking Utilities
        nmap
        bind
        curl
        wget
        wol
        rsync
        sshuttle
        iftop
        mailutils
        bluez-tools
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
