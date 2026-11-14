# Single sign-on to paal's RomM through his Authelia, at auth.paaa.al on his
# Home Assistant box. RomM is served to him at https://romm.paaa.al by that
# box's nginx, so the OIDC redirect goes there.
#
# The client secret stays out of this repo. Put it in the container once:
#
#   sudo nixos-container root-login paal
#   install -m 600 -o romm -g romm /dev/null /var/lib/romm/oidc.env
#   echo 'OIDC_CLIENT_SECRET=<secret>' > /var/lib/romm/oidc.env
#   systemctl restart romm
{ lib, ... }:
let
  authelia = "https://auth.paaa.al";
  romm = "https://romm.paaa.al";
in
{
  services.romm.extraEnvironment = {
    # Absolute URLs RomM builds, such as invite links, point at the proxy.
    ROMM_BASE_URL = romm;

    OIDC_ENABLED = "true";
    OIDC_PROVIDER = "authelia";
    OIDC_CLIENT_ID = "romm";
    OIDC_REDIRECT_URI = "${romm}/api/oauth/openid";
    OIDC_SERVER_APPLICATION_URL = authelia;
    # RomM matches Authelia users to its own by email, creating missing ones.
  };

  # Optional, so RomM still starts with password login before the secret is in.
  systemd.services = lib.genAttrs [ "romm" "romm-worker" "romm-scheduler" "romm-watcher" ] (_: {
    serviceConfig.EnvironmentFile = [ "-/var/lib/romm/oidc.env" ];
  });

  # *.paaa.al only resolves on the home LAN; the box is on this tailnet.
  networking.hosts."100.122.45.46" = [ "auth.paaa.al" ];
}
