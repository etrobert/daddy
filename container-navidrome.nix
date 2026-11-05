# A container's own Navidrome over the shared library, on its tailnet only.
{ config, ... }:
{
  services.navidrome = {
    enable = true;
    settings = {
      # All interfaces; the firewall below keeps it to the tailnet.
      Address = "0.0.0.0";
      MusicFolder = "/storage/music";
      # As on the host: not "always", or an incremental scan of an empty
      # library would purge everything.
      Scanner.PurgeMissing = "full";
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    config.services.navidrome.settings.Port
  ];
}
