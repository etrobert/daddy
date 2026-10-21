{ config, lib, ... }:
let
  cfg = config.services.slskd;
in
{
  services.slskd = {
    enable = true;
    # Placed by hand: SLSKD_SLSK_USERNAME, SLSKD_SLSK_PASSWORD, SLSKD_USERNAME, SLSKD_PASSWORD, SLSKD_API_KEY.
    environmentFile = "/etc/slskd.env";
    openFirewall = true;

    settings = {
      # Siblings on one filesystem: completion is a rename, not a copy.
      directories = {
        downloads = "/storage/slskd/downloads";
        incomplete = "/storage/slskd/incomplete";
      };

      # Share back what we fetched.
      shares = {
        directories = [ cfg.settings.directories.downloads ];
        # Without it the share never picks up new downloads.
        cache.retention = 60;
      };

      retention.files.complete = 72 * 60;

      # Only Caddy on loopback should reach it.
      web.ip_address = "127.0.0.1";
    };
  };

  services.caddy.virtualHosts."soulseek.etiennerobert.com".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString cfg.settings.web.port}
  '';

  systemd = {
    services.slskd = {
      # The module makes shares read-only, and the share is the downloads directory.
      serviceConfig.ReadOnlyPaths = lib.mkForce [ ];

      # Without the mount, downloads would fill the root filesystem.
      unitConfig.RequiresMountsFor = [ "/storage" ];
    };

    # ReadWritePaths= needs them to exist; the module only creates its StateDirectory.
    tmpfiles.settings.slskd =
      lib.genAttrs
        [
          "/storage/slskd"
          cfg.settings.directories.downloads
          cfg.settings.directories.incomplete
        ]
        (_: {
          d = {
            inherit (cfg) user group;
          };
        });
  };
}
