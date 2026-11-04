{ etrobert-setup, ... }:
{
  containers.peira = {
    autoStart = true;
    # Own network stack, so its tailscaled doesn't clash with the host's.
    privateNetwork = true;
    hostAddress = "10.233.1.1";
    localAddress = "10.233.1.2";
    enableTun = true;
    config =
      { config, ... }:
      {
        imports = [
          etrobert-setup.inputs.agenix.nixosModules.default
          ./users/soft.nix
        ];
        age.secrets.tailscale-authkey.file = "${etrobert-setup}/secrets/tailscale-authkey.age";
        services.tailscale = {
          enable = true;
          authKeyFile = config.age.secrets.tailscale-authkey.path;
        };
        services.openssh.enable = true;
        security.sudo.wheelNeedsPassword = false;
        system.stateVersion = "26.11";
      };
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "eno3";
  };
}
