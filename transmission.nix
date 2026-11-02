let
  dir = "/storage/downloads";
in
{
  services.transmission = {
    enable = true;
    openPeerPorts = true;
    # Readable by everyone, so downloads can be pulled over SSH as a normal user.
    downloadDirPermissions = "755";
    settings.download-dir = dir;
  };

  # nixpkgs declares transmission-setup without anything that starts it (since NixOS/nixpkgs@314c912811).
  systemd.services.transmission-setup.requiredBy = [ "transmission.service" ];

  # Without the mount, downloads would fill the root filesystem.
  systemd.services.transmission-setup.unitConfig.RequiresMountsFor = [ dir ];
  systemd.services.transmission.unitConfig.RequiresMountsFor = [ dir ];
}
