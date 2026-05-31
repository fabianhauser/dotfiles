{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./applications
    ./development
    ./environment
    ./fonts
    ./mimetypes
    ./multimedia
    ./security
    ./theme
  ];

  options.dotfiles.desktop.enable = lib.mkEnableOption "graphical desktop environment";

  config = lib.mkIf config.dotfiles.desktop.enable {
    home = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        NIXOS_WAYLAND = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };

      packages =
        with pkgs;
        [
          chromium
          thunar
          thunar-archive-plugin
          xfce4-appfinder
          mousepad
          bitwarden-desktop
          pinentry-rofi
        ]
        ++ [
          libreoffice-fresh
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
          jitsi-meet-electron
          rdesktop
        ]
        ++ [
          transmission_4
        ];

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
  };
}
