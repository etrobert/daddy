# RomM inside a user's container, served by its own nginx on port 80 of the
# container's tailnet. Its ROM library is /storage/roms on the host, bind-mounted
# at RomM's fixed library path, /var/lib/romm/library.
{ config, lib, ... }:
{
  services.romm = {
    enable = true;
    # The container's tailnet name; nginx also answers its tailnet IP.
    nginx.virtualHost = config.networking.hostName;
    # Metadata and cover art from sources that need no API key. ScreenScraper
    # also needs developer credentials, which this build doesn't ship.
    extraEnvironment = {
      LAUNCHBOX_API_ENABLED = "true";
      HASHEOUS_API_ENABLED = "true";
    };
  };

  # /storage/roms belongs to the users group, with setgid so new files stay in it.
  users.users.romm.extraGroups = [ "users" ];
  systemd.services = lib.genAttrs [ "romm" "romm-worker" "romm-scheduler" "romm-watcher" ] (_: {
    serviceConfig.UMask = "0002";
  });

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 80 ];
}
