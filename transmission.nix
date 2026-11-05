{ config, lib, ... }:
let
  dir = "/storage/downloads";
in
{
  services.transmission = {
    enable = true;
    openPeerPorts = true;
    # Readable by everyone, so downloads can be pulled over SSH as a normal user.
    downloadDirPermissions = "755";
    settings = {
      download-dir = dir;
      # All interfaces, so containers reach it. The firewall below keeps the
      # port closed on the public interface.
      rpc-bind-address = "0.0.0.0";
      # Transmission only answers loopback by default. Requests also come from
      # containers and from WireGuard peers' home networks, so the firewall
      # below decides who reaches the port instead.
      rpc-whitelist-enabled = false;
      # Lets containers be browsed by tailnet name, not only by IP, and Paal
      # through his own proxy.
      rpc-host-whitelist = lib.concatStringsSep "," (
        [ "transmission.paaa.al" ] ++ map (name: "${name},${name}.*") (lib.attrNames config.containers)
      );
    };
  };

  networking.firewall.interfaces = {
    # Every container, for host-proxy.nix. WireGuard peers: wireguard.nix.
    "ve-+".allowedTCPPorts = [ config.services.transmission.settings.rpc-port ];
  };

  # nixpkgs declares transmission-setup without anything that starts it (since NixOS/nixpkgs@314c912811).
  systemd.services.transmission-setup.requiredBy = [ "transmission.service" ];

  # Without the mount, downloads would fill the root filesystem.
  systemd.services.transmission-setup.unitConfig.RequiresMountsFor = [ dir ];
  systemd.services.transmission.unitConfig.RequiresMountsFor = [ dir ];
}
