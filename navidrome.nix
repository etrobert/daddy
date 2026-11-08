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

  # The folder Navidrome loads plugins from, with those in plugins below.
  pluginsFolder = config.services.navidrome.settings.Plugins.Folder;

  # The plugin's own defaults, from its manifest, but writing lyrics next to each
  # song without replacing existing files. Navidrome only accepts a complete config.
  lyricsConfig =
    pkgs.runCommand "nd-lyrics-config.json"
      {
        nativeBuildInputs = [
          pkgs.unzip
          pkgs.jq
        ];
      }
      ''
        unzip -p "$(grep -l nd-lyrics ${pluginsFolder}/*.ndp | head -1)" manifest.json | jq '
          .config.schema as $s
          | def defaults: to_entries | map(select(.value | has("default")) | {key, value: .value.default}) | from_entries;
          ($s.properties.providersList.items.properties | defaults | del(.provider)) as $provider
          | $s.properties | defaults
          | .providersList |= map($provider + .)
          | .writeLyrics = true
          | .overwriteLyrics = false
        ' > $out
      '';
in
{
  services.navidrome = {
    enable = true;
    # Lyrics from LRCLIB and other sources, for clients that ask; the web UI
    # doesn't show plugin lyrics yet.
    # Plugins are WebAssembly, hence the cross package set.
    plugins = [ pkgs.pkgsCross.wasi32.navidromePlugins.lyrics-plugin ];
    settings = {
      # All interfaces, so containers reach it for their tailnet. The firewall
      # below keeps the port closed on the public interface, where Caddy serves it.
      Address = "0.0.0.0";
      MusicFolder = "/storage/music";
      # Deleted files linger forever otherwise. Not "always": an incremental
      # scan of an unmounted library would purge everything.
      Scanner.PurgeMissing = "full";
      # Lyrics files and embedded lyrics first; the plugin only fills the gaps.
      LyricsPriority = ".lrc,.txt,embedded,nd-lyrics";
    };
  };

  # The sandbox binds MusicFolder at start; before the mount that is an empty dir.
  systemd.services.navidrome.unitConfig.RequiresMountsFor = [ MusicFolder ];

  # The lyrics plugin writes .lrc/.txt files next to the songs, so Navidrome gets
  # the library read-write instead of the module's read-only bind, and creates
  # files group-writable like the rest of the library.
  users.users.navidrome.extraGroups = [ "users" ];
  systemd.services.navidrome.serviceConfig = {
    BindPaths = [ MusicFolder ];
    BindReadOnlyPaths = lib.mkForce (
      [
        "${config.security.pki.caBundle}:/etc/ssl/certs/ca-certificates.crt"
        builtins.storeDir
        "/etc"
      ]
      ++ lib.optionals config.services.resolved.enable [
        "/run/systemd/resolve/stub-resolv.conf"
        "/run/systemd/resolve/resolv.conf"
      ]
    );
    UMask = lib.mkForce "0002";
  };

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

  # Navidrome finds plugins in Plugins.Folder but keeps them disabled until
  # enabled, which is stored in its database.
  systemd.services.navidrome-plugins = {
    description = "Enable Navidrome's plugins";
    after = [ "navidrome.service" ];
    requires = [ "navidrome.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ config.services.navidrome.finalPackage ];
    environment.ND_PLUGINS_FOLDER = pluginsFolder;
    serviceConfig = {
      Type = "oneshot";
      User = "navidrome";
      Group = "navidrome";
    };
    script = ''
      nd="navidrome --datafolder /var/lib/navidrome --nobanner"
      for _ in $(seq 30); do $nd plugin list > /dev/null 2>&1 && break; sleep 2; done
      $nd plugin rescan
      # Library access has to be granted before enabling, or it stays disabled.
      $nd plugin edit nd-lyrics --all-libraries --write-access --config-file ${lyricsConfig}
      $nd plugin enable nd-lyrics
    '';
  };

  networking.firewall.interfaces = {
    # Every container, for host-proxy.nix.
    "ve-+".allowedTCPPorts = [ Port ];
  };

  services.caddy.virtualHosts."navidrome.etiennerobert.com".extraConfig = /* caddy */ ''
    reverse_proxy 127.0.0.1:${toString Port}
  '';
}
