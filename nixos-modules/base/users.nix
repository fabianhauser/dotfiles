{
  lib,
  inputs,
  ...
}:

let
  users = {
    fhauser = {
      uid = 1000;
      isNormalUser = true;
      description = "Fabian Hauser";
      group = "fhauser";
      extraGroups = [
        "wheel"
        "video"
        "docker"
        "networkmanager"
        "libvirtd"
        "adbusers"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIPF8ZV7vhpbVvLxiKq8ANVusNUHMbtii5MuvjxCbVz7vSNVPo9OOLvYyDqhbRAWMTdQeGZVAaALBufKKmprDTRFMpnA7Ut4TFrdz/5DTaR2KEjJ7P75moH+0xooR/GsbzFGsNBSQSXK3u1igndPYEC/PqCHN++32kDo2wLqTB4VLrEovU3iq8BMckn329Bu1fGbXKTgDpEvUEEwFO2brQZLMmzILGF/v4B9ImEGtinAUNgDSfEpgPN23sdWQH9rwEClGv95JmWNf05tuVomhZzOBtCFoAno3XB1nj16avjsqJ3aGFY2CCcfsNrwKzhIotmm82bcI4BJuJIVRIKbZ1 cardno:000603507108"
      ];
    };
  };
in
{
  imports = [
    inputs.private.nixosModules.users # Contains hashedPasswords for users.
  ];

  users = {
    mutableUsers = false;
    groups = {
      fhauser.gid = 1000;
    };
    users = users // {
      root.openssh.authorizedKeys.keys =
        with lib;
        concatLists (
          mapAttrsToList (
            _name: user: if elem "wheel" user.extraGroups then user.openssh.authorizedKeys.keys else [ ]
          ) users
        );
    };
  };
}
