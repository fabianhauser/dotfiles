{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.dotfiles.desktop;
in
{
  config = mkIf cfg.enable {
    xsession.preferStatusNotifierItems = true;
    wayland.windowManager.sway.config.bars = [ ];

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        targets = [ "tray.target" ];
      };
      settings = [
        {
          position = "top";
          #height =
          modules-left = [
            "sway/mode"
            "sway/workspaces"
          ];
          modules-center = [ "sway/window" ];
          modules-right = [
            "idle_inhibitor"
            "backlight"
            "battery"
            "pulseaudio"
            "tray"
            "clock"
          ];
          backlight.format = " {percent}%";
          disk.format = " {percentage_used}%";
          clock.format = "{:%Y-%m-%d %H:%M}";
          "sway/workspaces" = {
            disable-scroll-wraparound = true;
            enable-bar-scroll = true;
            numeric-first = true;
          };

          battery = {
            interval = 60;
            states = {
              warning = 15;
              critical = 10;
            };
            format = " {capacity}% {time}"; # Icon: bolt
            format-discharging = "{icon} {capacity}% {time}";
            format-time = "{H}:{M}";
            format-icons = [
              "" # Icon: battery-full
              "" # Icon: battery-three-quarters
              "" # Icon: battery-half
              "" # Icon: battery-quarter
              "" # Icon: battery-empty
            ];
            tooltip = "true";
          };

          cpu = {
            interval = "5";
            format = " {usage}% ({load})"; # Icon: microchip
            states = {
              warning = "70";
              critical = "90";
            };
          };

          memory = {
            interval = "5";
            format = " {}%"; # Icon: microchip
            states = {
              warning = "70";
              critical = "90";
            };
          };

          "sway/mode" = {
            format = ''<span style="italic">  {}</span>''; # Icon: expand-arrows-alt
            tooltip = "false";
          };

          "sway/window" = {
            format = "{}";
            max-length = "120";
          };

          "sway/workspaces" = {
            all-outputs = false;
            disable-scroll = true;
            format = "{icon}";
            format-icons = {
              "10" = " 10";
              "11" = " 11";
              "12" = " 12";
              "13" = " 13";
            };
          };

          pulseaudio = {
            scroll-step = 3;
            format = "{icon}  {volume}%";
            format-bluetooth = "{icon}  {volume}%";
            format-muted = "🔇";
            format-icons = {
              headphones = "";
              handsfree = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "pavucontrol";
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = " active";
              deactivated = "";
            };
          };

          tray = {
            icon-size = "21";
            spacing = "10";
          };
        }
      ];

      style = ''
        @keyframes blink-warning {
            70% { color: @base05; }
            to { color: @base00; background-color: @base09; }
        }

        @keyframes blink-critical {
            70% { color: @base05; }
            to { color: @base00; background-color: @base08; }
        }

        #mode,
        #tray,
        #custom-keyboard-layout {
            padding: 0 5px;
        }

        #backlight {
            margin-right: 0;
            padding-right: 0;
        }

        #idle_inhibitor {
            margin-left: 0;
            padding-left: 0;
        }

        #battery {
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        #battery.warning { color: @base09; }
        #battery.critical { color: @base08; }

        #battery.warning.discharging {
            animation-name: blink-warning;
            animation-duration: 4s;
        }

        #battery.critical.discharging {
            animation-name: blink-critical;
            animation-duration: 3s;
        }

        #clock { font-weight: bold; }

        #cpu.warning { color: @base09; }
        #cpu.critical { color: @base08; }

        #memory {
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        #memory.warning { color: @base09; }

        #memory.critical {
            color: @base08;
            animation-name: blink-critical;
            animation-duration: 2s;
        }

        #mode {
            background: @base03;
            border-top: 2px solid @base05;
            padding-bottom: 2px;
        }

        #network.disconnected { color: @base09; }

        #custom-spotify { color: @base0B; }

        #temperature.critical { color: @base08; }

        #window { font-weight: bold; }

        #workspaces button {
            padding-left: 10px;
            padding-right: 10px;
            color: @base04;
        }
      '';
    };
  };
}
