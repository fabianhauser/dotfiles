{ pkgs, ... }:
{
  programs.ssh =
    let
      forceIdentityPrivate = {
        identityFile = toString (
          pkgs.writeText "fabian.hauser@qo.is.pub" ''
            ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIPF8ZV7vhpbVvLxiKq8ANVusNUHMbtii5MuvjxCbVz7vSNVPo9OOLvYyDqhbRAWMTdQeGZVAaALBufKKmprDTRFMpnA7Ut4TFrdz/5DTaR2KEjJ7P75moH+0xooR/GsbzFGsNBSQSXK3u1igndPYEC/PqCHN++32kDo2wLqTB4VLrEovU3iq8BMckn329Bu1fGbXKTgDpEvUEEwFO2brQZLMmzILGF/v4B9ImEGtinAUNgDSfEpgPN23sdWQH9rwEClGv95JmWNf05tuVomhZzOBtCFoAno3XB1nj16avjsqJ3aGFY2CCcfsNrwKzhIotmm82bcI4BJuJIVRIKbZ1 cardno:000610954665
          ''
        );
        identitiesOnly = true;
      };
    in
    {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "github.com" = forceIdentityPrivate // {
          user = "git";
        };
        "*" = {
          forwardAgent = false;
        };
      };
      extraConfig = ''
        IdentityAgent /run/user/1000/gnupg/S.gpg-agent.ssh
      '';
      #TODO: Authorized keys implementation, see https://github.com/nix-community/home-manager/pull/9
    };
}
