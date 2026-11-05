{ config, ... }:
let
  inherit (config.services.navidrome.settings) MusicFolder Port;
in
{
  services.navidrome = {
    enable = true;
    settings = {
      # All interfaces, so containers reach it for their tailnet. The firewall
      # below keeps the port closed on the public interface, where Caddy serves it.
      Address = "0.0.0.0";
      MusicFolder = "/storage/music";
      # Deleted files linger forever otherwise. Not "always": an incremental
      # scan of an unmounted library would purge everything.
      Scanner.PurgeMissing = "full";
    };
  };

  # The sandbox binds MusicFolder at start; before the mount that is an empty dir.
  systemd.services.navidrome.unitConfig.RequiresMountsFor = [ MusicFolder ];

  networking.firewall.interfaces = {
    tailscale0.allowedTCPPorts = [ Port ];
    # Every container, for host-proxy.nix.
    "ve-+".allowedTCPPorts = [ Port ];
  };

  services.caddy.virtualHosts."navidrome.etiennerobert.com".extraConfig = /* caddy */ ''
    reverse_proxy 127.0.0.1:${toString Port}
  '';
}
