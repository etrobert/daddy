# Imported by a container to serve the host's Transmission on its own tailnet.
{ hostAddress, port }:
{ pkgs, ... }:
{
  systemd.services.transmission-proxy = {
    description = "Forward Transmission's port to the host";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString port},fork,reuseaddr TCP:${hostAddress}:${toString port}";
      DynamicUser = true;
      Restart = "always";
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ port ];
}
