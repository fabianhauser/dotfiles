{
  pkgs,
  ...
}:

{

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
      opusTools
      flac
      lame
      id3lib
      id3v2 # icedax
      pasystray
      pavucontrol
      spotify
    ]
    ++ [
      # Imaging
      gimp
      hugin
      lensfun
      darktable
      inkscape
      ghostscript
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
      gst-vaapi
      gst-rtsp-server
      gst-libav
      gst-plugins-base
      gst-plugins-bad
      gst-plugins-good
      gst-plugins-ugly
    ]);
}
