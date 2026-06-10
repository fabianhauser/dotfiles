{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.desktop;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.swayest-workstyle ];

    xdg.configFile."sworkstyle/config.toml".source =
      (pkgs.formats.toml { }).generate "sworkstyle-config.toml"
        {
          fallback = "";
          separator = " ";
          matching = {
            "mvc" = "";
            "kitty" = "";
            "evolution" = "";
            "claws-mail" = "";
          };
        };

    systemd.user.services.sworkstyle = {
      Unit = {
        Description = "Swayest Workstyle (workspace icons)";
        After = [ "sway-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.swayest-workstyle}/bin/sworkstyle";
        Restart = "on-failure";
        RestartSec = "1";
      };
      Install.WantedBy = [ "sway-session.target" ];
    };
  };
}
