{
  pkgs,
  lib,
  config,
  ...
}:
let
  davinciResolveLauncher = pkgs.writeShellScriptBin "davinci-resolve-launcher" ''
    set -euo pipefail
    export QT_QPA_PLATFORM=xcb
    export QT_AUTO_SCREEN_SCALE_FACTOR=0
    export NIXPKGS_ALLOW_UNFREE=1
    exec nix run --impure nixpkgs#davinci-resolve -- "$@"
  '';
in
{
  config = lib.mkIf config.dotfiles.desktop.enable {
    programs.mpv = {
      enable = true;
      config = {
        hwdec = "auto-safe";
        vo = "gpu";
        gpu-context = "wayland";
        force-window = true;
        profile = "gpu-hq";
      };
      scripts = [ pkgs.mpvScripts.mpris ];
    };
    home.packages =
      with pkgs;
      [
        v4l-utils
        playerctl
        yt-dlp
      ]
      ++ [
        # Audio
        gnome-sound-recorder
        enblend-enfuse
        ffmpeg
        #sox mencoder
        vorbis-tools
        vorbisgain
        opus-tools
        flac
        lame
        id3lib
        id3v2 # icedax
        pavucontrol
        (if config.targets.genericLinux.enable then riff else spotify)
      ]
      ++ [
        # Imaging
        gimp
        hugin
        lensfun
        darktable
        inkscape
        ghostscript
        davinciResolveLauncher
      ]
      ++ [
        # Codecs for Audio and Video
        libdv
        libdvbpsi # librtmp
        xvidcore
        x264
      ]
      ++ (with gst_all_1; [
        gstreamer
        gst-rtsp-server
        gst-libav
        gst-plugins-base
        gst-plugins-bad
        gst-plugins-good
        gst-plugins-ugly
      ]);
  };
}
