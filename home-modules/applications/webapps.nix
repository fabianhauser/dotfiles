{ pkgs, ... }:

let
  web-app =
    name: url:
    pkgs.writeScriptBin name ''
      #!${pkgs.stdenv.shell}
      exec ${pkgs.chromium}/bin/chromium --user-data-dir=$HOME/.config/chromium-app-${name} --app="${url}"
    '';
  whatsapp = web-app "whatsapp" "https://web.whatsapp.com/";
  threema = web-app "threema" "https://web-beta.threema.ch/";
in
{
  home.packages = [
    whatsapp
    threema
  ];
}
