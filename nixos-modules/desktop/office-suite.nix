{
  pkgs,
  ...
}:

{

  # Hamster
  environment.systemPackages = with pkgs; [
    hamster
  ];
  programs.hamster.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    #    google-fonts # Breaks fwesome
    lalezar-fonts
    nahid-fonts
    nika-fonts
    agave
    aileron
    amiri
    andagii
    #andika # Breaks Font-Awesome
    ankacoder
    ankacoder-condensed
    aurulent-sans
    caladea
    cantarell-fonts
    carlito
    cascadia-code
    #charis-sil # Breaks Font-Awesome
    cherry
    cnstrokeorder
    comfortaa
    comic-neue
    comic-relief
    #    corefonts # breaks fawesome
    culmus
    clearlyU
    creep
    crimson
    dejavu_fonts
    dina-font
    #doulos-sil # Breaks Font-Awesome
    cabin
    camingo-code
    cooper-hewitt
    #d2coding
    dosis
    dosemu_fonts
    eb-garamond
    eunomia
    ferrum
    #    fixedsys-excelsior # Breaks fawesome
    emacs-all-the-icons-fonts
    encode-sans
    envypn-font
    fantasque-sans-mono
    fira
    fira-code
    fira-code-symbols
    fira-mono
    #gentium
    #gentium-book-basic
    #gohufont
    #go-font
    #gubbi-font
    #gyre-fonts
    #hack-font
    ##helvetica-neue-lt-std
    #hanazono
    #hermit
    #hyperscrypt-font
    #ia-writer-duospace
    #inconsolata
    #inconsolata-lgc
    ##input-fonts
    #inriafonts
    #iosevka
    #iosevka-bin
    #ipafont
    #ipaexfont
    #iwona
    #jetbrains-mono
    #jost
    #kanji-stroke-order-font
    #latinmodern-math
    #lato
    #league-of-moveable-type
    ##liberation-sans-narrow
    #libertine
    #libertinus
    #libre-baskerville
    #libre-bodoni
    #libre-caslon
    #libre-franklin
    #lmmath
    #lmodern
    #luculent
    #marathi-cursive
    #manrope
    #material-design-icons
    #material-icons
    #meslo-lg
    #migmix
    #migu
    #medio
    #mno16
    #monoid
    #mononoki
    #montserrat
    #mph_2b_damase
    #mplus-outline-fonts
    #mro-unicode
    #myrica
    #nafees
    #nanum-gothic-coding
    #national-park-typeface
    #office-code-pro
    #oldstandard
    #oldsindhi
    #open-dyslexic
    open-sans
    orbitron
    overpass
    oxygenfonts
    #pecita
    #paratype-pt-mono # Breaks fawseome
    #paratype-pt-sans # Breaks fawseome
    #paratype-pt-serif # Breaks fawseome
    penna
    poly
    powerline-fonts
    profont
    proggyfonts
    public-sans
    redhat-official-fonts
    route159
    #sarasa-gothic
    seshat
    scheherazade
    #signwriting
    stix-otf
    stix-two
    quattrocento
    quattrocento-sans
    raleway
    recursive
    rhodium-libre
    roboto
    roboto-mono
    roboto-slab
    hasklig
    siji
    source-code-pro
    source-sans-pro
    source-serif-pro
    tamsyn
    theano
    tenderness
    terminus_font
    tipa
    twemoji-color-font
    twitter-color-emoji
    ubuntu-classic
    #ucs-fonts
    ultimate-oldschool-pc-font-pack
    victor-mono
    work-sans
    wqy_microhei
    wqy_zenhei
    xits-math
    xkcd-font
    yanone-kaffeesatz
    norwester-font
    font-awesome
  ]; # Generated with `cd /home/fhauser/projects/nixos/nixpkgs/pkgs/data/fonts; echo *`
}
