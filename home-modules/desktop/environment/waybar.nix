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
              "group/spaces"
            ];
            modules-center = [ "sway/window" ];
            modules-right = [
              "group/system-tray"
              "tray"
              "battery"
              "clock"
            ];
            "group/spaces" = {
              orientation = "horizontal";
              modules = spaceModuleNames;
            };
            "group/system-tray" = {
              orientation = "horizontal";
              modules = [
                "idle_inhibitor"
                "backlight"
                "pulseaudio"
              ];
            };
            backlight.format = " {percent}%";
            disk.format = " {percentage_used}%";
            clock.format = "{:%Y-%m-%d %H:%M}";
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
        )
      ];

      style = ''
        * {
            border: none;
            border-radius: 0;
            min-height: 0;
            margin: 0;
            padding: 0;
            font-size: 13px;
        }

        window#waybar {
            background-color: transparent;
            color: @base05;
        }

        tooltip {
            background-color: @base01;
            border: 1px solid @base02;
            border-radius: 8px;
        }
        tooltip label { color: @base05; }

        #custom-project,
        #mode,
        #spaces,
        #system-tray,
        #tray,
        #battery,
        #clock,
        #window {
            margin: 4px 5px;
            padding: 6px 14px;
            background-color: @base01;
            border-radius: 20px;
            color: @base05;
        }

        #custom-project {
            font-weight: bold;
            color: @base0D;
        }

        #mode {
            color: @base09;
            font-style: italic;
        }

        #window { font-weight: bold; }
        #clock  { font-weight: bold; }

        #spaces { padding: 4px 6px; }

        #custom-space-0, #custom-space-1, #custom-space-2, #custom-space-3,
        #custom-space-4, #custom-space-5, #custom-space-6, #custom-space-7,
        #custom-space-8, #custom-space-9 {
            min-width: 22px;
            padding: 2px 8px;
            margin: 0 2px;
            border-radius: 14px;
            background-color: transparent;
            color: @base04;
            transition: all 0.2s ease;
        }

        #custom-space-0.focused, #custom-space-1.focused, #custom-space-2.focused,
        #custom-space-3.focused, #custom-space-4.focused, #custom-space-5.focused,
        #custom-space-6.focused, #custom-space-7.focused, #custom-space-8.focused,
        #custom-space-9.focused {
            background-color: @base0D;
            color: @base00;
        }

        #custom-space-0.visible, #custom-space-1.visible, #custom-space-2.visible,
        #custom-space-3.visible, #custom-space-4.visible, #custom-space-5.visible,
        #custom-space-6.visible, #custom-space-7.visible, #custom-space-8.visible,
        #custom-space-9.visible {
            background-color: @base02;
            color: @base05;
        }

        #custom-space-0.empty, #custom-space-1.empty, #custom-space-2.empty,
        #custom-space-3.empty, #custom-space-4.empty, #custom-space-5.empty,
        #custom-space-6.empty, #custom-space-7.empty, #custom-space-8.empty,
        #custom-space-9.empty {
            min-width: 0;
            padding: 0;
            margin: 0;
            background: transparent;
        }

        #system-tray { padding: 0 4px; }
        #system-tray #idle_inhibitor,
        #system-tray #backlight,
        #system-tray #pulseaudio {
            padding: 6px 8px;
            background: transparent;
        }
        #idle_inhibitor { color: @base0E; }
        #backlight      { color: @base0A; }
        #pulseaudio     { color: @base0C; }

        #battery          { color: @base0B; }
        #battery.warning  { color: @base09; }
        #battery.critical { color: @base08; }

        @keyframes blink-warning {
            70% { color: @base05; }
            to  { color: @base00; background-color: @base09; }
        }
        @keyframes blink-critical {
            70% { color: @base05; }
            to  { color: @base00; background-color: @base08; }
        }
        #battery.warning.discharging {
            animation: blink-warning 4s linear infinite alternate;
        }
        #battery.critical.discharging {
            animation: blink-critical 3s linear infinite alternate;
        }

        #tray { padding: 4px 10px; }
      '';
    };
  };
}
