{ pkgs, ... }:
{
  systemd.user.services.swayidle =
    let
      lock = "${pkgs.swaylock}/bin/swaylock --hide-keyboard-layout --daemonize --show-failed-attempts --color=000000";
      logTimeCmd = "${pkgs.coreutils}/bin/date --rfc-3339=seconds >> ~/locklog";
      idleCmd = (action: ''${pkgs.sway}/bin/swaymsg "output * dpms ${action}" && ${logTimeCmd}'');
      timeout-screens-off = 600;
      timeout-lock = 630;
      timeout-suspend = 1800;
    in
    {
      Unit = {
        Description = "Idle Manager for Wayland";
        Documentation = [ "man:swayidle(1)" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Environment = "PATH=${pkgs.bash}/bin";
        ExecStart = ''
          ${pkgs.swayidle}/bin/swayidle -w -d \
            timeout ${toString timeout-lock}        '${lock}' \
            timeout ${toString timeout-screens-off} '${idleCmd "off"}' \
              resume '${idleCmd "on"}' \
            timeout ${toString timeout-suspend} '${pkgs.systemd}/bin/systemctl suspend' \
            lock '${lock}' \
            before-sleep '${lock}';
        ''; # TODO: Make this configurable and add home-manager module. (Requires sway with systemd-target support)
      };
      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };

  catppuccin.swaylock.enable = true;
}
