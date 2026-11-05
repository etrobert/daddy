{ config, ... }:
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
      # All interfaces, as tailscale0 may not exist yet when this starts. The
      # firewall below keeps the port closed on the public interface.
      rpc-bind-address = "0.0.0.0";
      # Transmission only answers loopback by default.
      rpc-whitelist = "127.0.0.1,::1,100.*.*.*,${config.containers.peira.localAddress}";
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    config.services.transmission.settings.rpc-port
  ];

  # nixpkgs declares transmission-setup without anything that starts it (since NixOS/nixpkgs@314c912811).
  systemd.services.transmission-setup.requiredBy = [ "transmission.service" ];

  # Without the mount, downloads would fill the root filesystem.
  systemd.services.transmission-setup.unitConfig.RequiresMountsFor = [ dir ];
  systemd.services.transmission.unitConfig.RequiresMountsFor = [ dir ];
}
