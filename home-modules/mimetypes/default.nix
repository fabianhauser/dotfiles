{
  ...
}:
{

  xdg.mimeApps = rec {
    enable = true;
    associations.added = defaultApplications;
    defaultApplications =
      let
        browser = [ "firefox.desktop" ];
        email = [ "org.gnome.Evolution.desktop" ];
        doc-editor = [ "writer.desktop" ];
        sheet-editor = [ "calc.desktop" ];
        presentation-editor = [ "impress.desktop" ];
        pdf = [ "org.gnome.Papers.desktop" ];
        image = [
          "org.gnome.Loupe.desktop"
          "gimp.desktop"
        ];
        image-vector = [ "org.inkscape.Inkscape.desktop" ];
        ebooks = [ "calibre-ebook-viewer.desktop" ];
        code-general = [ "codium.desktop" ];
        video = [ "mpv.desktop" ];
        compression = [ "org.gnome.Nautilus.desktop" ];
      in
      {
        "text/html" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/chrome" = browser;
        "application/xhtml+xml" = browser;
        "application/x-extension-htm" = browser;
        "application/x-extension-html" = browser;
        "application/x-extension-shtml" = browser;
        "application/x-extension-xhtml" = browser;
        "application/x-extension-xht" = browser;
        "x-scheme-handler/mailto" = email;
        "text/calendar" = email;

        "application/vnd.oasis.opendocument.text" = doc-editor;
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = doc-editor;
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = sheet-editor;
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = presentation-editor;
        "application/vnd.oasis.opendocument.presentation" = presentation-editor;
        "application/pdf" = pdf;
        "application/x-extension-pdf" = pdf;
        "application/epub+zip" = ebooks;

        "text/plain" = code-general;
        "application/json" = code-general;
        "text/markdown" = code-general;

        "image/png" = image;
        "image/jpg" = image;
        "image/jpeg" = image;
        "image/x-tga" = image;
        "image/tiff" = image;
        "image/x-canon-cr2" = image;
        "application/x-ptoptimizer-script" = [ "hugin.desktop" ];
        "image/svg+xml" = image-vector;

        "video/mp4" = video;
        "video/x-matroska" = video;

        "application/zip" = compression;
      };
  };
}
