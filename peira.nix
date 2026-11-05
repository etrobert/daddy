{
  containers.peira = {
    autoStart = true;
    flake = "github:etrobert/setup/deploy#peira";
    # The first start builds the system from the flake.
    timeoutStartSec = "30min";
    # Own network stack, so its tailscaled doesn't clash with other containers'.
    privateNetwork = true;
    hostAddress = "10.233.1.1";
    localAddress = "10.233.1.2";
    enableTun = true;
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "eno3";
  };
}
