# Imported by a container to serve the host's services on its own tailnet.
# ports maps a service name to its port on the host, e.g. { slskd = 5030; }.
{ hostAddress, ports }:
{ lib, pkgs, ... }:
{
  systemd.services = lib.mapAttrs' (
    name: port:
    lib.nameValuePair "${name}-proxy" {
      description = "Forward ${name}'s port to the host";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString port},fork,reuseaddr TCP:${hostAddress}:${toString port}";
        DynamicUser = true;
        Restart = "always";
      };
    }
  ) ports;

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.attrValues ports;
}
