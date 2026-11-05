{ config, ... }:
{
  services.slskd = {
    enable = true;
    environmentFile = config.sops.templates."slskd.env".path;
    openFirewall = true;

    settings = {
      shares = {
        directories = [ "/storage/music" ];
        # Without it the share never picks up new files.
        cache.retention = 60;
      };

      # All interfaces, so containers reach it for their tailnet. The firewall
      # below keeps the port closed on the public interface, where Caddy serves it.
      web.ip_address = "0.0.0.0";
    };
  };

  networking.firewall.interfaces = {
    # Every container, for host-proxy.nix.
    "ve-+".allowedTCPPorts = [ config.services.slskd.settings.web.port ];
  };

  # Lidarr imports by moving files out, so its user needs write
  # access here. The default ACL passes that on to every new download.
  systemd.tmpfiles.settings."10-slskd-lidarr"."/var/lib/slskd/downloads"."A+".argument =
    let
      lidarr = toString config.ids.uids.lidarr;
    in
    "user:${lidarr}:rwx,default:user:${lidarr}:rwx";

  sops = {
    secrets = {
      "slskd/soulseek-password" = { };
      "slskd/web-password" = { };
      "slskd/api-key" = { };
    };
    templates."slskd.env" = {
      content = ''
        SLSKD_SLSK_USERNAME=soft
        SLSKD_SLSK_PASSWORD=${config.sops.placeholder."slskd/soulseek-password"}
        SLSKD_USERNAME=soulseek
        SLSKD_PASSWORD=${config.sops.placeholder."slskd/web-password"}
        SLSKD_API_KEY=${config.sops.placeholder."slskd/api-key"}
      '';
      restartUnits = [ "slskd.service" ];
    };
  };

  services.caddy.virtualHosts."soulseek.etiennerobert.com".extraConfig = /* caddy */ ''
    reverse_proxy 127.0.0.1:${toString config.services.slskd.settings.web.port}
  '';
}
