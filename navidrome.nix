{ config, ... }:
let
  inherit (config.services.navidrome.settings) MusicFolder Port;
in
{
  services.navidrome = {
    enable = true;
    settings = {
      MusicFolder = "/storage/music";
      # Deleted files linger forever otherwise. Not "always": an incremental
      # scan of an unmounted library would purge everything.
      Scanner.PurgeMissing = "full";
    };
  };

  # The sandbox binds MusicFolder at start; before the mount that is an empty dir.
  systemd.services.navidrome.unitConfig.RequiresMountsFor = [ MusicFolder ];

  services.caddy.virtualHosts."navidrome.etiennerobert.com".extraConfig = /* caddy */ ''
    reverse_proxy 127.0.0.1:${toString Port}
  '';
}
