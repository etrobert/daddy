{
  containers.paal = {
    autoStart = true;
    # Own network stack, so its tailscaled doesn't clash with other containers'.
    privateNetwork = true;
    hostAddress = "10.233.2.1";
    localAddress = "10.233.2.2";
    enableTun = true;

    config = {
      imports = [ ./users/paal.nix ];

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
