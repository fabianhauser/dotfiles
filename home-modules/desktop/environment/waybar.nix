{
  lib,
  config,
  dotfilesSwaySpaces,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.dotfiles.desktop;
  spacesCli = "${dotfilesSwaySpaces.wrapper}/bin/dotfiles-sway-spaces";
  waybarSpaceBin = "${dotfilesSwaySpaces.waybarSpace}/bin/dotfiles-sway-spaces-waybar-space";
  waybarProjectBin = "${dotfilesSwaySpaces.waybarProject}/bin/dotfiles-sway-spaces-waybar-project";
  spaceRange = lib.range 0 9;
  spaceModuleNames = map (n: "custom/space-${toString n}") spaceRange;
  spaceModuleConfigs = lib.listToAttrs (
    map (
      n:
      lib.nameValuePair "custom/space-${toString n}" {
        exec = "${waybarSpaceBin} ${toString n}";
        return-type = "json";
        on-click = "${spacesCli} focus-space ${toString n}";
        on-click-right = "${spacesCli} move-to-space ${toString n}";
        format = "{}";
      }
    ) spaceRange
  );
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
        (
          spaceModuleConfigs
          // {
            position = "top";
            #height =
            modules-left = [
              "custom/project"
              "sway/mode"
            ]
            ++ spaceModuleNames;
            modules-center = [ "sway/window" ];
            modules-right = [
              "idle_inhibitor"
              "backlight"
              "battery"
              "pulseaudio"
              "tray"
              "clock"
            ];
            backlight.format = " {percent}%";
            disk.format = " {percentage_used}%";
            clock.format = "{:%Y-%m-%d %H:%M}";
            "custom/project" = {
              exec = waybarProjectBin;
              return-type = "json";
              on-click = "${spacesCli} menu-project";
              format = "{}";
            };

            battery = {
              interval = 60;
              states = {
                warning = 15;
                critical = 10;
              };
              format = " {capacity}% {time}"; # Icon: bolt
              format-discharging = "{icon} {capacity}% {time}";
              format-time = "{H}:{M}";
              format-icons = [
                "" # Icon: battery-full
                "" # Icon: battery-three-quarters
                "" # Icon: battery-half
                "" # Icon: battery-quarter
                "" # Icon: battery-empty
              ];
              tooltip = "true";
            };

            cpu = {
              interval = "5";
              format = " {usage}% ({load})"; # Icon: microchip
              states = {
                warning = "70";
                critical = "90";
              };
            };

            memory = {
              interval = "5";
              format = " {}%"; # Icon: microchip
              states = {
                warning = "70";
                critical = "90";
              };
            };

            "sway/mode" = {
              format = ''<span style="italic">  {}</span>''; # Icon: expand-arrows-alt
              tooltip = "false";
            };

            "sway/window" = {
              format = "{}";
              max-length = "120";
            };

            pulseaudio = {
              scroll-step = 3;
              format = "{icon}  {volume}%";
              format-bluetooth = "{icon}  {volume}%";
              format-muted = "🔇";
              format-icons = {
                headphones = "";
                handsfree = "";
                headset = "";
                phone = "";
                portable = "";
                car = "";
                default = [
                  ""
                  ""
                  ""
                ];
              };
              on-click = "pavucontrol";
            };

            idle_inhibitor = {
              format = "{icon}";
              format-icons = {
                activated = " active";
                deactivated = "";
              };
            };

            tray = {
              icon-size = "21";
              spacing = "10";
            };
          }
        )
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

        * {
            border: none;
            font-size: 13px;
        }

        window#waybar {
            background-color: @base00;
            border-bottom: 2px solid @base01;
            color: @base05;
        }

        tooltip {
            background-color: @base01;
            border: 1px solid @base02;
        }

        tooltip label { color: @base05; }

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
        #tray {
            padding: 0 8px;
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

        #battery.warning  { color: @base09; }
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

        #cpu.warning  { color: @base09; }
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
        #temperature.critical { color: @base08; }
        #window { font-weight: bold; }

        #custom-project {
            font-weight: bold;
            padding: 0 12px;
            color: @base0D;
            border-bottom: 3px solid @base0D;
        }

        #custom-space-0, #custom-space-1, #custom-space-2, #custom-space-3,
        #custom-space-4, #custom-space-5, #custom-space-6, #custom-space-7,
        #custom-space-8, #custom-space-9 {
            padding: 0 8px;
            color: @base04;
            border-bottom: 3px solid transparent;
            transition: all 0.15s ease;
        }

        #custom-space-0.visible { color: @base05; border-bottom-color: @base08; }
        #custom-space-1.visible { color: @base05; border-bottom-color: @base09; }
        #custom-space-2.visible { color: @base05; border-bottom-color: @base0A; }
        #custom-space-3.visible { color: @base05; border-bottom-color: @base0B; }
        #custom-space-4.visible { color: @base05; border-bottom-color: @base0C; }
        #custom-space-5.visible { color: @base05; border-bottom-color: @base0D; }
        #custom-space-6.visible { color: @base05; border-bottom-color: @base0E; }
        #custom-space-7.visible { color: @base05; border-bottom-color: @base0F; }
        #custom-space-8.visible { color: @base05; border-bottom-color: @base07; }
        #custom-space-9.visible { color: @base05; border-bottom-color: @base06; }

        #custom-space-0.focused { background-color: @base08; color: @base00; border-bottom-color: @base08; }
        #custom-space-1.focused { background-color: @base09; color: @base00; border-bottom-color: @base09; }
        #custom-space-2.focused { background-color: @base0A; color: @base00; border-bottom-color: @base0A; }
        #custom-space-3.focused { background-color: @base0B; color: @base00; border-bottom-color: @base0B; }
        #custom-space-4.focused { background-color: @base0C; color: @base00; border-bottom-color: @base0C; }
        #custom-space-5.focused { background-color: @base0D; color: @base00; border-bottom-color: @base0D; }
        #custom-space-6.focused { background-color: @base0E; color: @base00; border-bottom-color: @base0E; }
        #custom-space-7.focused { background-color: @base0F; color: @base00; border-bottom-color: @base0F; }
        #custom-space-8.focused { background-color: @base07; color: @base00; border-bottom-color: @base07; }
        #custom-space-9.focused { background-color: @base06; color: @base00; border-bottom-color: @base06; }

        #custom-space-0.empty, #custom-space-1.empty, #custom-space-2.empty,
        #custom-space-3.empty, #custom-space-4.empty, #custom-space-5.empty,
        #custom-space-6.empty, #custom-space-7.empty, #custom-space-8.empty,
        #custom-space-9.empty {
            min-width: 0;
            padding: 0;
            margin: 0;
            border: none;
            background: transparent;
        }
      '';
    };
  };
}
