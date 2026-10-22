{ config, lib, ... }:
let
  cfg = config.services.slskd;
  # slskd's default when settings.directories.downloads is unset.
  downloads = "/var/lib/slskd/downloads";
in
{
  services.slskd = {
    enable = true;
    # Placed by hand: SLSKD_SLSK_USERNAME, SLSKD_SLSK_PASSWORD, SLSKD_USERNAME, SLSKD_PASSWORD, SLSKD_API_KEY.
    environmentFile = "/etc/slskd.env";
    openFirewall = true;

    settings = {
      # Share back what we fetched.
      shares = {
        directories = [ downloads ];
        # Without it the share never picks up new downloads.
        cache.retention = 60;
      };

      # Only Caddy on loopback should reach it.
      web.ip_address = "127.0.0.1";
    };
  };

  services.caddy.virtualHosts."soulseek.etiennerobert.com".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString cfg.settings.web.port}
  '';

  # The module makes shares read-only, and the share is the downloads directory.
  systemd.services.slskd.serviceConfig.ReadOnlyPaths = lib.mkForce [ ];
}
