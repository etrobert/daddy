etrobert-setup: {
  users.users.soft = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = etrobert-setup.lib.sshKeys.soft;
  };
}
