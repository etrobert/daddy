# daddy's WireGuard, for everyone in wireguard-peers.nix. Peers reach the shared
# services at 10.234.0.1, but neither each other nor anything beyond daddy.
{ config, lib, ... }:
let
  port = 51820;
  peers = import ./wireguard-peers.nix;

  services = [
    config.services.transmission.settings.rpc-port
    config.services.slskd.settings.web.port
    config.services.lidarr.settings.server.port
    config.services.navidrome.settings.Port
  ];

  routed = lib.concatMap (peer: [ "${peer.ip}/32" ] ++ peer.networks) peers;
in
{
  assertions = [
    {
      # WireGuard routes each address to one peer only.
      assertion = lib.allUnique routed;
      message = "wireguard-peers.nix: every ip and network must be unique, got ${toString routed}";
    }
  ];

  sops.secrets."wireguard/server-private-key" = { };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.234.0.1/24" ];
    listenPort = port;
    privateKeyFile = config.sops.secrets."wireguard/server-private-key".path;
    # No endpoints: peers connect and keep the tunnel open themselves.
    peers = map (peer: {
      name = peer.name;
      inherit (peer) publicKey;
      allowedIPs = [ "${peer.ip}/32" ] ++ peer.networks;
    }) peers;
  };

  networking.firewall = {
    allowedUDPPorts = [ port ];
    interfaces.wg0.allowedTCPPorts = services;
    # The host forwards for its containers, but nothing in or out of wg0.
    extraCommands = ''
      iptables -I FORWARD -i wg0 -j DROP
      iptables -I FORWARD -o wg0 -j DROP
    '';
    extraStopCommands = ''
      iptables -D FORWARD -i wg0 -j DROP || true
      iptables -D FORWARD -o wg0 -j DROP || true
    '';
  };
}
