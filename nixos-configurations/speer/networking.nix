{ ... }:
{
  networking = {
    networkmanager.enable = true;
    useDHCP = false;

  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
    authKeyFile = "/secrets/wireguard/tailscale-key";
    extraUpFlags = [
      "--operator"
      "fhauser"
      "--accept-routes"
      "--exit-node=100.64.0.6"
      "--login-server=https://vpn.qo.is"
    ];
  };
}
