{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (config.services.navidrome.settings) MusicFolder Port;

  # Created when missing, each with its password at navidrome/<user>-password in
  # secrets.yaml. Changes made later in Navidrome, such as a new password, stay.
  users = [ "paal" ];
  secret = user: "navidrome/${user}-password";
in
{
  services.navidrome = {
    enable = true;
    settings = {
      # All interfaces, so containers reach it for their tailnet. The firewall
      # below keeps the port closed on the public interface, where Caddy serves it.
      Address = "0.0.0.0";
      MusicFolder = "/storage/music";
      # Deleted files linger forever otherwise. Not "always": an incremental
      # scan of an unmounted library would purge everything.
      Scanner.PurgeMissing = "full";
    };
  };

  # The sandbox binds MusicFolder at start; before the mount that is an empty dir.
  systemd.services.navidrome.unitConfig.RequiresMountsFor = [ MusicFolder ];

  sops.secrets = lib.genAttrs (map secret users) (_: {
    owner = "navidrome";
  });

  systemd.services.navidrome-users = {
    description = "Create Navidrome's users";
    # Navidrome creates its database on start.
    after = [ "navidrome.service" ];
    requires = [ "navidrome.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      config.services.navidrome.package
      pkgs.util-linux
    ];
    # script runs its command through $SHELL, which for navidrome is nologin.
    environment.SHELL = lib.getExe pkgs.bash;
    serviceConfig = {
      Type = "oneshot";
      User = "navidrome";
      Group = "navidrome";
    };
    script = ''
      nd="navidrome --datafolder /var/lib/navidrome --nobanner"
      for _ in $(seq 30); do $nd user list > /dev/null 2>&1 && break; sleep 2; done
      existing=$($nd user list | cut -d, -f2)
    ''
    + lib.concatMapStrings (user: ''
      if ! grep -qx ${lib.escapeShellArg user} <<< "$existing"; then
        password=$(cat ${config.sops.secrets.${secret user}.path})
        # It only reads the password from a terminal, which script provides.
        printf '%s\n%s\n' "$password" "$password" |
          script -qec "$nd user create -u ${lib.escapeShellArg user}" /dev/null
      fi
    '') users;
  };

  networking.firewall.interfaces = {
    # Every container, for host-proxy.nix.
    "ve-+".allowedTCPPorts = [ Port ];
  };

  services.caddy.virtualHosts."navidrome.etiennerobert.com".extraConfig = /* caddy */ ''
    reverse_proxy 127.0.0.1:${toString Port}
  '';
}
