# Join the tailnet once after deploy with `sudo tailscale up`; the login
# persists in /var/lib/tailscale.
{
  services.tailscale = {
    enable = true;
    # Lets peers reach the box directly instead of through a relay.
    openFirewall = true;
  };
}
