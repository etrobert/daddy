{
  containers.peira = {
    autoStart = true;
    # Own network stack, so its tailscaled doesn't clash with the host's.
    privateNetwork = true;
    hostAddress = "10.233.1.1";
    localAddress = "10.233.1.2";
    enableTun = true;
    config = {
      services.tailscale.enable = true;
      system.stateVersion = "26.11";
    };
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "eno3";
  };
}
