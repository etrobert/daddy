{
  users.users.soft = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSr+lSqswj8+pzE2Aym5AAjpHHO+48n4IhVk8y7oEpk soft@aaron"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINTE+enHTxryvtFonEwoY4Fsz8WHSX0gizS7+NLM9Q4M soft@leod"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILe8/rx4MPrvwQBU1cy5qkhBgnRALS6Jzc9I20EcBnAx soft@tower"
    ];
  };
}
