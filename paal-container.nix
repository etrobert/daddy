{ config, ... }:
{
  sops.secrets."paal-container/tailscale-auth-key" = { };

  containers.paal = {
    autoStart = true;
    # Own network stack, so its tailscaled doesn't clash with the host's.
    privateNetwork = true;
    hostAddress = "10.233.2.1";
    localAddress = "10.233.2.2";
    enableTun = true;

    bindMounts."/run/tailscale-auth-key" = {
      hostPath = config.sops.secrets."paal-container/tailscale-auth-key".path;
      isReadOnly = true;
    };

    config = {
      imports = [ ./users/paal.nix ];

      services.tailscale = {
        enable = true;
        # Only used while logged out; the login persists in /var/lib/tailscale.
        authKeyFile = "/run/tailscale-auth-key";
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
