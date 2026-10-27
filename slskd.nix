{ config, ... }:
{
  services.slskd = {
    enable = true;
    # Placed by hand: SLSKD_SLSK_USERNAME, SLSKD_SLSK_PASSWORD, SLSKD_USERNAME, SLSKD_PASSWORD.
    environmentFile = "/etc/slskd.env";
    openFirewall = true;

    settings = {
      shares = {
        directories = [ "/storage/music" ];
        # Without it the share never picks up new files.
        cache.retention = 60;
      };

      # Only Caddy on loopback should reach it.
      web.ip_address = "127.0.0.1";
    };
  };

  services.caddy.virtualHosts."soulseek.etiennerobert.com".extraConfig = /* caddy */ ''
    reverse_proxy 127.0.0.1:${toString config.services.slskd.settings.web.port}
  '';
}
