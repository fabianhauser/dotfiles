{
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.dotfiles.desktop-environment;
in
{
  config = mkIf cfg.enable {
    xsession.preferStatusNotifierItems = true;
    wayland.windowManager.sway.config.bars = [ ];

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "tray.target";
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
        /* =============================================================================
        *
        * Waybar configuration
        *
        * Configuration reference: https://github.com/Alexays/Waybar/wiki/Configuration
        *
        * =========================================================================== */

        /* -----------------------------------------------------------------------------
        * Keyframes
        * -------------------------------------------------------------------------- */

        @keyframes blink-warning {
            70% {
                color: white;
            }

            to {
                color: white;
                background-color: orange;
            }
        }

        @keyframes blink-critical {
            70% {
              color: white;
            }

            to {
                color: white;
                background-color: red;
            }
        }


        /* -----------------------------------------------------------------------------
        * Base styles
        * -------------------------------------------------------------------------- */

        /* Reset all styles */
        * {
            border: none;
            border-radius: 0;
            min-height: 0;
            margin: 0;
            padding: 0;
        }

        /* The whole bar */
        #waybar {
            background: #323232;
            color: white;
            /*font-family: Cantarell, Noto Sans, sans-serif;*/
            font-size: 13px;
        }

        /* Each module */
        #battery,
        #clock,
        #cpu,
        #custom-keyboard-layout,
        #memory,
        #mode,
        #network,
        #pulseaudio,
        #temperature,
        #backlight,
        #idle_inhibitor,
        #tray {
            margin-left: 5px;
            margin-right: 5px;
            padding-left: 5px;
            padding-right: 5px;
            /*border-right: solid 1px black;*/
        }

        #backlight {
          margin-right: 0;
          padding-right: 0;
        }

        #idle_inhibiter {
          margin-left: 0;
          padding-left: 0;
        }


        /* -----------------------------------------------------------------------------
        * Module styles
        * -------------------------------------------------------------------------- */

        #battery {
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        #battery.warning {
            color: orange;
        }

        #battery.critical {
            color: red;
        }

        #battery.warning.discharging {
            animation-name: blink-warning;
            animation-duration: 4s;
        }

        #battery.critical.discharging {
            animation-name: blink-critical;
            animation-duration: 3s;
        }

        #clock {
            font-weight: bold;
        }

        #cpu {
          /* No styles */
        }

        #cpu.warning {
            color: orange;
        }

        #cpu.critical {
            color: red;
        }

        #memory {
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        #memory.warning {
            color: orange;
        }

        #memory.critical {
            color: red;
            animation-name: blink-critical;
            animation-duration: 2s;
        }

        #mode {
            background: #64727D;
            border-top: 2px solid white;
            /* To compensate for the top border and still have vertical centering */
            padding-bottom: 2px;
        }

        #network {
            /* No styles */
        }

        #network.disconnected {
            color: orange;
        }

        #pulseaudio {
            /* No styles */
        }

        #pulseaudio.muted {
            /* No styles */
        }

        #custom-spotify {
            color: rgb(102, 220, 105);
        }

        #temperature {
            /* No styles */
        }

        #temperature.critical {
            color: red;
        }

        #tray {
            /* No styles */
        }

        #window {
            font-weight: bold;
        }

        #workspaces button {
            border-top: 2px solid transparent;
            /* To compensate for the top border and still have vertical centering */
            padding-bottom: 2px;
            padding-left: 10px;
            padding-right: 10px;
            color: #888888;
        }

        #workspaces button.focused {
            border-color: #4c7899;
            color: white;
            background-color: #285577;
        }

        #workspaces button.urgent {
            border-color: #c9545d;
            color: #c9545d;
        }
      '';
    };
  };
}
