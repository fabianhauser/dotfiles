{
  pkgs,
  lib,
  ...
}:
{
  #  systemd.user.services.kanshi.Install.WantedBy = "home-manager-fhauser.service"; # TODO: Upstream array type of systemdTarget
  services.kanshi = {
    enable = true;
    settings =
      let
        mkScreen = display: position: {
          inherit (display.output) criteria;
          inherit position;
          status = "enable";
        };
        mkProfile = name: outputs: {
          profile = {
            inherit name outputs;
            exec = backgroundCommand;
          };
        };
        # Can be applied by profile.exec
        backgroundPicturePath = "~/shares/cloud.qo.is/pictures/backgrounds";
        backgroundCommand = ''
          ${pkgs.sway}/bin/swaymsg "output * bg `find ${backgroundPicturePath} -type f | shuf -n 1` fill"
        '';

        screens = {
          x1-screen.output = {
            criteria = "California Institute of Technology 0x1404 Unknown";
            scale = null;
          };
          tallinn-4k.output = {
            criteria = "HP Inc. HP Z27 CN482201RP";
            scale = 1.2;
          };
          chur-dell.output = {
            criteria = "Dell Inc. DELL P2720DC 22JPK53";
            scale = null;
          };
          chur-small.output = {
            criteria = "Eizo Nanao Corporation EV2450 92395086";
            scale = null;
          };
          tallinn-thinkvision.output = {
            criteria = "Lenovo Group Limited LEN P24h-20 V307DA61";
            scale = null;
          };
          tallinn-tv.output = {
            criteria = "Samsung Electric Company SAMSUNG 0x01000E00";
            scale = 2.0;
          };
          walrueti-buero.output = {
            criteria = "Dell Inc. DELL U2719D 12DGV13";
            scale = null;
          };
        };
      in
      with lib;
      (attrValues screens)
      ++ (with screens; [
        (mkProfile "mobile-only" [
          (mkScreen x1-screen "0,0")
        ])
        (mkProfile "desktop-oly" [
          (mkScreen tallinn-4k "0,0")
        ])
        (mkProfile "home-dock" [
          (mkScreen x1-screen "0,120")
          (mkScreen tallinn-4k "1920,0")
        ])
        (mkProfile "saba-desk" [
          (mkScreen x1-screen "0,0")
          (mkScreen tallinn-thinkvision "1920,0")
        ])
        (mkProfile "tv" [
          ((mkScreen x1-screen "0,0") // { status = "disable"; })
          (mkScreen tallinn-tv "0,0")
        ])
        (mkProfile "walrueti" [
          (mkScreen x1-screen "0,0")
          (mkScreen walrueti-buero "1920,0")
        ])
      ]);
  };
}
