{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
{

  options.dotfiles.hardware.modem-em120r-gl.enable = lib.mkEnableOption "Enable EM120R GL Support";

  config = lib.mkIf config.dotfiles.hardware.modem-em120r-gl.enable {
    environment.systemPackages = with pkgs; [
      modemmanager
      libmbim
    ];

    environment.etc."ModemManager/fcc-unlock.d/1eac:1001".source =
      let
        package = inputs.fcc-unlock.packages.${config.nixpkgs.hostPlatform.system}.default;
      in
      "${package}/bin/fcc-unlock";
  };
}
