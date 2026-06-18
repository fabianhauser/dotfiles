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
    arg="''${1:-}"

    # User-facing verbs vs. swaysome's vocabulary:
    #   space   = swaysome "group"     (per-output column, first digit)
    #   project = swaysome "workspace" (row across spaces,  second digit)
    # Mod+N            -> focus-space N        (which output column is focused)
    # Mod+Ctrl+N       -> focus-project N      (switch to project N's spaces)
    # Mod+Shift+N      -> move-to-space N
    # Mod+Ctrl+Shift+N -> move-to-project N

    current_project() {
      local name digits
      name=$(${swaymsg} -r -t get_workspaces | ${jq} -r '.[] | select(.focused) | .name')
      [[ "$name" =~ ^([0-9]+) ]] || return
      digits="''${BASH_REMATCH[1]:0:2}"
      printf '%02d' "$digits" | tail -c 1
    }

    case "$cmd" in
      init)            ${swaysome} init "''${arg:-0}" ;;
      rearrange)       ${swaysome} rearrange-workspaces ;;
      focus-space)     ${swaysome} focus-group "$arg" ;;
      focus-project)   ${swaysome} focus-all-outputs "$arg" ;;
      move-to-space)   ${swaysome} move-to-group "$arg" ;;
      move-to-project) ${swaysome} move "$arg" ;;
      current-project) current_project ;;
      menu-project)
        choice=$(seq 0 9 | ${fuzzel} --dmenu --prompt "Project: ")
        [[ -n "''${choice:-}" ]] && ${swaysome} focus-all-outputs "$choice"
        ;;
      *)
        echo "Usage: dotfiles-sway-spaces {init|rearrange|focus-space|focus-project|move-to-space|move-to-project|current-project|menu-project} [N]" >&2
        exit 1
        ;;
    esac
  '';

  waybarSpace = pkgs.writeScriptBin "dotfiles-sway-spaces-waybar-space" ''
    #!${pythonEnv}/bin/python3
    import i3ipc, json, re, sys

    if len(sys.argv) != 2 or not sys.argv[1].isdigit():
        sys.stderr.write("usage: dotfiles-sway-spaces-waybar-space <space 0-9>\n")
        sys.exit(2)
    my_space = sys.argv[1]

    ${pySpaceProject}

    def emit(ipc, *_):
        workspaces = ipc.get_workspaces()
        focused = next((w for w in workspaces if w.focused), None)
        if focused is None:
            return
        sp = space_project(focused.name)
        if sp is None:
            return
        _, project = sp
        target = f"{my_space}{project}"
        existing = next(
            (
                w for w in workspaces
                if (sp2 := space_project(w.name)) is not None
                and f"{sp2[0]}{sp2[1]}" == target
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
            payload = {"text": my_space, "class": " ".join(classes)}
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
    ):
        ipc.on(event, emit)
    ipc.main()
  '';

  waybarProject = pkgs.writeScriptBin "dotfiles-sway-spaces-waybar-project" ''
    #!${pythonEnv}/bin/python3
    import i3ipc, json, re, sys

    ${pySpaceProject}

    def emit(ipc, *_):
        focused = next((w for w in ipc.get_workspaces() if w.focused), None)
        if focused is None:
            return
        sp = space_project(focused.name)
        if sp is None:
            return
        _, project = sp
        sys.stdout.write(
            json.dumps({"text": project, "tooltip": f"Project {project}"}) + "\n"
        )
        sys.stdout.flush()

    ipc = i3ipc.Connection()
    emit(ipc)
    for event in (
        "workspace::focus",
        "workspace::init",
        "workspace::empty",
        "workspace::rename",
        "output::change",
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
