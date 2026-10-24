# The web UI listens on a unix socket only the shared group can open, so the
# socket's permissions are the access control. To use it:
#   ssh -NL 9091:/run/transmission/rpc.sock <you>@51.91.29.38
# then open http://localhost:9091.
let
  dir = "/storage/shared/transmission";
in
{
  services.transmission = {
    enable = true;
    group = "shared";
    openPeerPorts = true;
    downloadDirPermissions = "2775";
    settings = {
      download-dir = dir;
      incomplete-dir = "${dir}/.incomplete";
      rpc-bind-address = "unix:/run/transmission/rpc.sock";
      rpc-socket-mode = "0770";
      umask = "002";
    };
  };

  systemd.services.transmission-setup.unitConfig.RequiresMountsFor = dir;
  systemd.services.transmission.unitConfig.RequiresMountsFor = dir;
}
