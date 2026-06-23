{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.desktop;
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.i3ipc ]);
  swaysome = "${pkgs.swaysome}/bin/swaysome";
  swaymsg = "${pkgs.sway}/bin/swaymsg";
  jq = "${pkgs.jq}/bin/jq";
  fuzzel = "${pkgs.fuzzel}/bin/fuzzel";

  # Workspace names are <space><project> (swaysome's <group><workspace>).
  # Sworkstyle may append icons/separators to names, so only the leading
  # one or two digits are stable. Space 0 produces single-digit names
  # (e.g. "3"), which is why we pad to two digits before slicing.
  pySpaceProject = ''
    def space_project(name):
        m = re.match(r'^\d+', name)
        if not m:
            return None
        digits = m.group(0)[:2]
        padded = f"{int(digits):02}"
        return padded[0], padded[1]
  '';

  wrapper = pkgs.writeShellScriptBin "dotfiles-sway-spaces" ''
    set -euo pipefail
    cmd="''${1:-help}"
    shift || true

    # User-facing verbs vs. swaysome's vocabulary:
    #   space   = swaysome "group"     (per-output column, first digit)
    #   project = swaysome "workspace" (row across spaces,  second digit)
    # Mod+N            -> focus-space N        (which output column is focused)
    # Mod+Shift+N      -> move-to-space N
    # Mod+F{N} (Esc=0) -> focus-project N      (switch to project N's spaces)
    # Mod+Shift+F{N}   -> move-to-project N

    # Per-project state is one JSON file per project digit, session-only.
    projects_dir="''${XDG_RUNTIME_DIR:-/tmp}/dotfiles-sway-spaces/projects"
    project_file() { printf '%s/%s.json' "$projects_dir" "$1"; }

    # Per-project memory of the last focused space, so returning to a project
    # restores focus to the screen you last used there. State is temporary
    # (XDG_RUNTIME_DIR is wiped on logout) but survives sway reloads.
    state_dir="''${XDG_RUNTIME_DIR:-/tmp}/dotfiles-sway-spaces"
    state_file="$state_dir/last-space.json"

    # Prints "<space> <project>" of the currently focused workspace.
    focused_space_project() {
      local name digits
      name=$(${swaymsg} -r -t get_workspaces | ${jq} -r '.[] | select(.focused) | .name')
      [[ "$name" =~ ^([0-9]+) ]] || return 1
      digits=$(printf '%02d' "''${BASH_REMATCH[1]:0:2}")
      printf '%s %s\n' "''${digits:0:1}" "''${digits:1:1}"
    }

    current_project() {
      local sp pr
      read -r sp pr < <(focused_space_project) || return
      printf '%s' "$pr"
    }

    remember_focused_space() {
      local sp pr tmp
      read -r sp pr < <(focused_space_project) || return 0
      mkdir -p "$state_dir"
      tmp=$(mktemp "$state_dir/.XXXXXX")
      ${jq} --arg p "$pr" --arg s "$sp" '. + {($p): $s}' \
        <(cat "$state_file" 2>/dev/null || printf '{}') > "$tmp"
      mv "$tmp" "$state_file"
    }

    restore_focused_space() {
      local pr="$1" sp
      [[ -f "$state_file" ]] || return 0
      sp=$(${jq} -r --arg p "$pr" '.[$p] // empty' "$state_file") || return 0
      [[ -n "$sp" ]] && ${swaysome} focus-group "$sp"
    }

    focus_project() {
      remember_focused_space
      ${swaysome} focus-all-outputs "$1"
      restore_focused_space "$1"
    }

    resolve_project() {
      if [[ "''${1:-}" =~ ^[0-9]$ ]]; then printf '%s' "$1"; else current_project; fi
    }

    get_name() {
      local f
      f=$(project_file "$1")
      [[ -f "$f" ]] || return 0
      ${jq} -r '.name // empty' "$f"
    }

    set_name() {
      local proj="$1" name="$2" f tmp
      f=$(project_file "$proj")
      mkdir -p "$projects_dir"
      tmp=$(mktemp)
      if [[ -f "$f" ]]; then
        ${jq} --arg name "$name" '.name = $name' "$f" > "$tmp"
      else
        ${jq} -n --arg name "$name" '{ name: $name }' > "$tmp"
      fi
      mv "$tmp" "$f"
    }

    clear_name() {
      local proj="$1" f tmp
      f=$(project_file "$proj")
      [[ -f "$f" ]] || return 0
      tmp=$(mktemp)
      ${jq} 'del(.name)' "$f" > "$tmp"
      if [[ "$(${jq} -r 'keys | length' "$tmp")" == "0" ]]; then
        rm -f "$f" "$tmp"
      else
        mv "$tmp" "$f"
      fi
    }

    notify_change() { ${swaymsg} -t send_tick project-name >/dev/null; }

    prompt_name() {
      if [[ -n "$1" ]]; then
        printf '%s\n' "$1" | ${fuzzel} --dmenu --prompt "Name: "
      else
        ${fuzzel} --dmenu --prompt "Name: " < /dev/null
      fi
    }

    case "$cmd" in
      init)            ${swaysome} init "''${1:-0}" ;;
      rearrange)       ${swaysome} rearrange-workspaces ;;
      focus-space)     ${swaysome} focus-group "''${1:-}" ;;
      focus-project)   focus_project "''${1:-}" ;;
      move-to-space)   ${swaysome} move-to-group "''${1:-}" ;;
      move-to-project) ${swaysome} move "''${1:-}" ;;
      current-project) current_project ;;
      get-name)        get_name "$(resolve_project "''${1:-}")" ;;
      set-name)
        if [[ "''${1:-}" =~ ^[0-9]$ ]]; then proj="$1"; shift; else proj=$(current_project); fi
        [[ -n "$proj" ]] || { echo "no current project" >&2; exit 1; }
        name="$*"
        [[ -n "$name" ]] || name=$(prompt_name "$(get_name "$proj")") || exit 0
        if [[ -z "$name" ]]; then clear_name "$proj"; else set_name "$proj" "$name"; fi
        notify_change
        ;;
      clear-name)
        proj=$(resolve_project "''${1:-}")
        [[ -n "$proj" ]] || exit 0
        clear_name "$proj"
        notify_change
        ;;
      menu-project)
        choice=$(for n in $(seq 0 9); do
          nm=$(get_name "$n")
          if [[ -n "$nm" ]]; then printf '%s: %s\n' "$n" "$nm"; else printf '%s\n' "$n"; fi
        done | ${fuzzel} --dmenu --prompt "Project: ") || exit 0
        [[ -n "''${choice:-}" ]] || exit 0
        [[ "$choice" =~ ^([0-9]) ]] && focus_project "''${BASH_REMATCH[1]}"
        ;;
      *)
        echo "Usage: dotfiles-sway-spaces {init|rearrange|focus-space|focus-project|move-to-space|move-to-project|current-project|menu-project|get-name|set-name|clear-name} [N] [NAME...]" >&2
        exit 1
        ;;
    esac
  '';

  waybarSpace = pkgs.writeScriptBin "dotfiles-sway-spaces-waybar-space" ''
    #!${pythonEnv}/bin/python3
    import i3ipc, json, os, re, sys

    if len(sys.argv) != 2 or not sys.argv[1].isdigit():
        sys.stderr.write("usage: dotfiles-sway-spaces-waybar-space <space 0-9>\n")
        sys.exit(2)
    my_space = sys.argv[1]
    my_output = os.environ["WAYBAR_OUTPUT_NAME"]

    ${pySpaceProject}

    def current_on_output(workspaces):
        # The space shown on this bar's screen is the visible workspace on this
        # output; its project is the bar's current project.
        return next(
            (w for w in workspaces if w.output == my_output and w.visible),
            None,
        )

    def emit(ipc, *_):
        # A monitor hosts several spaces of the current project; only one is
        # visible, the rest hidden but live. List every space with a workspace
        # on this output in the current project, not just the visible one.
        workspaces = ipc.get_workspaces()
        current = current_on_output(workspaces)
        if current is None:
            return
        sp = space_project(current.name)
        if sp is None:
            return
        _, project = sp
        target = f"{my_space}{project}"
        existing = next(
            (
                w for w in workspaces
                if (sp2 := space_project(w.name)) is not None
                and f"{sp2[0]}{sp2[1]}" == target
                and w.output == my_output
            ),
            None,
        )
        if existing is None:
            payload = {"text": "", "class": "empty"}
        else:
            classes = []
            if existing.focused:
                classes.append("focused")
            elif existing.visible:
                classes.append("visible")
            if existing.urgent:
                classes.append("urgent")
            icons = re.sub(r'^\d+', "", existing.name).rstrip()
            payload = {"text": f"{my_space}{icons}", "class": " ".join(classes)}
        sys.stdout.write(json.dumps(payload) + "\n")
        sys.stdout.flush()

    ipc = i3ipc.Connection()
    emit(ipc)
    for event in (
        "workspace::focus",
        "workspace::init",
        "workspace::empty",
        "workspace::rename",
        "output::change",
        "window::urgent",
    ):
        ipc.on(event, emit)
    ipc.main()
  '';

  waybarProject = pkgs.writeScriptBin "dotfiles-sway-spaces-waybar-project" ''
    #!${pythonEnv}/bin/python3
    import i3ipc, json, os, re, sys

    ${pySpaceProject}

    def project_name(project):
        runtime = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
        path = os.path.join(runtime, "dotfiles-sway-spaces", "projects", f"{project}.json")
        try:
            with open(path) as f:
                return json.load(f).get("name") or None
        except (OSError, ValueError):
            return None

    def emit(ipc, *_):
        focused = next((w for w in ipc.get_workspaces() if w.focused), None)
        if focused is None:
            return
        sp = space_project(focused.name)
        if sp is None:
            return
        _, project = sp
        name = project_name(project)
        if name:
            payload = {"text": f"{project}: {name}", "tooltip": f"Project {project}: {name}"}
        else:
            payload = {"text": project, "tooltip": f"Project {project}"}
        sys.stdout.write(json.dumps(payload) + "\n")
        sys.stdout.flush()

    ipc = i3ipc.Connection()
    emit(ipc)
    for event in (
        "workspace::focus",
        "workspace::init",
        "workspace::empty",
        "workspace::rename",
        "output::change",
        "tick",
    ):
        ipc.on(event, emit)
    ipc.main()
  '';

  swaySpacesPkgs = {
    inherit wrapper waybarSpace waybarProject;
  };
in
{
  config = {
    _module.args.dotfilesSwaySpaces = swaySpacesPkgs;
    home.packages = lib.mkIf cfg.enable [
      pkgs.swaysome
      wrapper
      waybarSpace
      waybarProject
    ];
  };
}
