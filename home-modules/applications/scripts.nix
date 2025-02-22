{ pkgs, ... }:

let
  suspend = pkgs.writeScriptBin "suspend" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.systemd}/bin/systemctl suspend
  '';
  passbemenu = pkgs.writeScriptBin "passbemenu" ''
    #!${pkgs.stdenv.shell}
    shopt -s nullglob globstar

    typeit=0
    if [[ $1 == "--type" ]]; then
      typeit=1
      shift
    fi

    export BEMENU_BACKEND=wayland

    prefix=''${PASSWORD_STORE_DIR-~/.password-store}
    password_files=( $(find -L "$prefix" -type f -name '*.gpg') )
    password_files=( "''${password_files[@]#"$prefix"/}" )
    password_files=( "''${password_files[@]%.gpg}" )

    password=$(printf '%s\n' "''${password_files[@]}" | \
      ${pkgs.bemenu}/bin/bemenu --list 20 --ignorecase --prompt 'Pass: ' "$@")

    [[ -n $password ]] || exit

    password_value=$(${pkgs.pass-wayland}/bin/pass show "$password" | tail -1 2>/dev/null)
    ${pkgs.wtype}/bin/wtype "''${password_value}"
  '';
  bt-connect = pkgs.writeShellApplication {
    name = "bt";
    meta.description = "Connect known Bluetooth device";
    runtimeInputs = [ pkgs.bluez ];
    text = ''
      COMMAND="connect"
      if [[ $1 == "--disconnect" ]]; then
        COMMAND="disconnect"
        shift
      fi

      DEVICE="";

      case "$1" in
        headset)
          DEVICE="88:C9:E8:7A:11:C2"
        ;;
        *)
          echo "Unknown Device" >&2
          exit 1
        ;;
      esac

      exec bluetoothctl $COMMAND $DEVICE
    '';
  };
in
{
  home.packages = [
    passbemenu
    suspend
    bt-connect
  ];
}
