{
  config,
  lib,
  ...
}:

{
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "unrar"

      "steam"
      "steam-run"
      "steam-original"
      "steam-unwrapped"

      "hplip"

      "google-chrome"
      "spotify"
      "spotify-unwrapped"
      "discord"
      "teamviewer"
      "todoist-electron"
      "todoist-electron-8.10.1"
      "obsidian"

      "davinci-resolve"
      "davinci-resolve-18.6.3"

      "lightworks"
      "lightworks-2023.1"
      "nvidia-cg-toolkit-3.1"
      "nvidia-cg-toolkit"

      "corefonts"
      "camingo-code"
      "helvetica-neue-lt-std"
      #"kochi-substitute-naga10"
      "ttf-envy-code-r"
      "vista-fonts"
      "vista-fonts-chs"
      "xkcd-font-unstable"
      "xkcd-font"
      "xkcd-font-unstable-2017-08-24"
      "ricty"

      "pycharm-professional"
      "idea-ultimate"
      "android-studio-stable"
      "android-studio-beta"

      "vmware-view"
    ];
}
