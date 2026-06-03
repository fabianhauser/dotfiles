{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.desktop.security;
  identityFile = toString (
    pkgs.writeText "fabian.hauser@qo.is.pub" ''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIPF8ZV7vhpbVvLxiKq8ANVusNUHMbtii5MuvjxCbVz7vSNVPo9OOLvYyDqhbRAWMTdQeGZVAaALBufKKmprDTRFMpnA7Ut4TFrdz/5DTaR2KEjJ7P75moH+0xooR/GsbzFGsNBSQSXK3u1igndPYEC/PqCHN++32kDo2wLqTB4VLrEovU3iq8BMckn329Bu1fGbXKTgDpEvUEEwFO2brQZLMmzILGF/v4B9ImEGtinAUNgDSfEpgPN23sdWQH9rwEClGv95JmWNf05tuVomhZzOBtCFoAno3XB1nj16avjsqJ3aGFY2CCcfsNrwKzhIotmm82bcI4BJuJIVRIKbZ1 cardno:000610954665
    ''
  );
in
{
  config = lib.mkIf cfg.enable {
    programs.ssh.settings = {
      "github.com" = {
        User = "git";
        IdentityFile = identityFile;
        IdentitiesOnly = true;
      };
      "*" = {
        IdentityAgent = "/run/user/%i/gnupg/S.gpg-agent.ssh";
      };
    };
  };
}
