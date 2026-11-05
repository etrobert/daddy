# A user's own container, reached over their own tailnet. subnet must be unique
# among containers.
{
  name,
  subnet,
  user,
  # Host paths to share, as in containers.<name>.bindMounts.
  bindMounts ? { },
  # Extra NixOS modules for inside the container.
  modules ? [ ],
  # Optionally also join the user's own WireGuard network, as a peer of their
  # router: { address, endpoint, publicKey, allowedIPs }. Its keys are in
  # secrets.yaml at wireguard/<name>-private-key and wireguard/<name>-preshared-key.
  wireguard ? null,
}:
{ config, lib, ... }:
let
  hostAddress = "10.233.${toString subnet}.1";

  ports = {
    transmission = config.services.transmission.settings.rpc-port;
    slskd = config.services.slskd.settings.web.port;
    lidarr = config.services.lidarr.settings.server.port;
    navidrome = config.services.navidrome.settings.Port;
  };

  wgKey = kind: config.sops.secrets."wireguard/${name}-${kind}".path;
in
{
  # Otherwise it would bind the empty directories beneath unmounted datasets.
  systemd.services."container@${name}".unitConfig.RequiresMountsFor = lib.attrNames bindMounts;

  sops.secrets = lib.mkIf (wireguard != null) {
    "wireguard/${name}-private-key" = { };
    "wireguard/${name}-preshared-key" = { };
  };

  # Containers share the host's kernel and can't load modules themselves.
  boot.kernelModules = lib.optional (wireguard != null) "wireguard";

  containers.${name} = {
    autoStart = true;
    # Own network stack, for its own tailscaled.
    privateNetwork = true;
    inherit hostAddress;
    localAddress = "10.233.${toString subnet}.2";
    enableTun = true;
    bindMounts =
      bindMounts
      // lib.optionalAttrs (wireguard != null) {
        ${wgKey "private-key"} = { };
        ${wgKey "preshared-key"} = { };
      };

    config = {
      imports = [
        user
        (import ./host-proxy.nix { inherit hostAddress ports; })
      ]
      ++ modules;

      networking.wireguard.interfaces.wg0 = lib.mkIf (wireguard != null) {
        ips = [ wireguard.address ];
        privateKeyFile = wgKey "private-key";
        peers = [
          {
            inherit (wireguard) endpoint publicKey allowedIPs;
            presharedKeyFile = wgKey "preshared-key";
            # The router can only reach the container while it keeps the
            # tunnel open, as the container sits behind the host's NAT.
            persistentKeepalive = 25;
            # The endpoint is a dynamic DNS name.
            dynamicEndpointRefreshSeconds = 300;
          }
        ];
      };

      # The host's services, as on the tailnet.
      networking.firewall.interfaces.wg0.allowedTCPPorts = lib.mkIf (wireguard != null) (
        lib.attrValues ports
      );

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
