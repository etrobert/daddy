{ config, ... }:
let
  slskdApiKey = config.sops.secrets."slskd/api-key".path;
in
{
  containers.peira = {
    autoStart = true;
    flake = "github:etrobert/setup/deploy#peira";
    # The first start builds the system from the flake.
    timeoutStartSec = "30min";
    # Own network stack, so its tailscaled doesn't clash with the host's.
    privateNetwork = true;
    hostAddress = "10.233.1.1";
    localAddress = "10.233.1.2";
    enableTun = true;

    # Same paths inside, so Lidarr needs no remote path mappings.
    bindMounts = {
      "/storage/music".isReadOnly = false;
      "/storage/downloads" = { };
      "/var/lib/slskd/downloads" = { };
      ${slskdApiKey} = { };
    };
  };

  systemd.services."container@peira".unitConfig.RequiresMountsFor = [
    "/storage/music"
    "/storage/downloads"
  ];

  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "eno3";
  };
}
