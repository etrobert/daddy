# A user's own container, reached over their own tailnet. subnet must be unique
# among containers.
{
  name,
  subnet,
  user,
}:
{ config, ... }:
let
  hostAddress = "10.233.${toString subnet}.1";
in
{
  containers.${name} = {
    autoStart = true;
    # Own network stack, so its tailscaled doesn't clash with the host's.
    privateNetwork = true;
    inherit hostAddress;
    localAddress = "10.233.${toString subnet}.2";
    enableTun = true;

    config = {
      imports = [
        user
        (import ./host-proxy.nix {
          inherit hostAddress;
          ports = {
            transmission = config.services.transmission.settings.rpc-port;
            slskd = config.services.slskd.settings.web.port;
          };
        })
      ];

      # Join the tailnet once with `sudo tailscale up`; the login persists in /var/lib/tailscale.
      services.tailscale = {
        enable = true;
        # Lets peers reach the container directly instead of through a relay.
        openFirewall = true;
      };

      # Reached over the tailnet only: the container has no public address.
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

      users.mutableUsers = false;
      security.sudo.wheelNeedsPassword = false;

      system.stateVersion = "26.11";
    };
  };
}
