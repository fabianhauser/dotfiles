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

        #backlight,
        #battery,
        #clock,
        #idle_inhibitor,
        #memory,
        #network,
        #pulseaudio,
        #temperature,
        #window,
        #mode,
        #tray,
        #custom-keyboard-layout {
            padding: 0 10px;
        }

        #backlight      { color: @base0A; }
        #battery        { color: @base0B; }
        #pulseaudio     { color: @base0C; }
        #idle_inhibitor { color: @base0E; }

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

        #sway-workspace-0 { background-color: alpha(@base08, 0.4); color: @base05; border-bottom: 3px solid @base08; }
        #sway-workspace-1 { background-color: alpha(@base09, 0.4); color: @base05; border-bottom: 3px solid @base09; }
        #sway-workspace-2 { background-color: alpha(@base0A, 0.4); color: @base05; border-bottom: 3px solid @base0A; }
        #sway-workspace-3 { background-color: alpha(@base0B, 0.4); color: @base05; border-bottom: 3px solid @base0B; }
        #sway-workspace-4 { background-color: alpha(@base0C, 0.4); color: @base05; border-bottom: 3px solid @base0C; }
        #sway-workspace-5 { background-color: alpha(@base0D, 0.4); color: @base05; border-bottom: 3px solid @base0D; }
        #sway-workspace-6 { background-color: alpha(@base0E, 0.4); color: @base05; border-bottom: 3px solid @base0E; }
        #sway-workspace-7 { background-color: alpha(@base0F, 0.4); color: @base05; border-bottom: 3px solid @base0F; }
        #sway-workspace-8 { background-color: alpha(@base07, 0.4); color: @base05; border-bottom: 3px solid @base07; }
        #sway-workspace-9 { background-color: alpha(@base06, 0.4); color: @base05; border-bottom: 3px solid @base06; }

        #sway-workspace-0.focused { background-color: @base08; color: @base00; }
        #sway-workspace-1.focused { background-color: @base09; color: @base00; }
        #sway-workspace-2.focused { background-color: @base0A; color: @base00; }
        #sway-workspace-3.focused { background-color: @base0B; color: @base00; }
        #sway-workspace-4.focused { background-color: @base0C; color: @base00; }
        #sway-workspace-5.focused { background-color: @base0D; color: @base00; }
        #sway-workspace-6.focused { background-color: @base0E; color: @base00; }
        #sway-workspace-7.focused { background-color: @base0F; color: @base00; }
        #sway-workspace-8.focused { background-color: @base07; color: @base00; }
        #sway-workspace-9.focused { background-color: @base06; color: @base00; }
      '';
    };
  };
}
