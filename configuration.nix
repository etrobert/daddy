{
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;

  boot.loader.systemd-boot.enable = true;

  networking.hostId = "eb21b81a";
  services.zfs.autoScrub.enable = true;

  networking.hostName = "daddy";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.mutableUsers = false;
  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.autoUpgrade = {
    enable = true;
    flake = "github:etrobert/daddy#daddy";
    # --upgrade only updates channels; nixos-rebuild warns on every run.
    upgrade = false;
    dates = "*:0/5";
    allowReboot = true;
  };

  system.stateVersion = "26.11";
}
