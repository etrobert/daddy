{ lib, pkgs, ... }:
let
  music = "/storage/music";

  configFile = (pkgs.formats.yaml { }).generate "beets-config.yaml" {
    directory = music;
    import.move = true;
  };

  beets-import = pkgs.writeShellApplication {
    name = "beets-import";
    runtimeInputs = [
      pkgs.beets
      pkgs.coreutils
      pkgs.jq
      pkgs.util-linux
      pkgs.systemd
    ];
    text = /* bash */ ''
      dir=$(jq --raw-output .localDirectoryName <<< "$SLSKD_SCRIPT_DATA")

      # Library database and state file, outside the share.
      export BEETSDIR=/var/lib/slskd/beets
      mkdir --parents "$BEETSDIR"

      # flock: concurrent events would race on beets' SQLite library.
      # systemd-cat: slskd only reads a script's output once it exits, so a full pipe would hang beets.
      exec flock "$BEETSDIR/lock" systemd-cat --identifier=beets-import \
        beet --config ${configFile} import --quiet "$dir"
    '';
  };
in
{
  services.slskd.settings.integration.scripts.beets-import = {
    on = [ "DownloadDirectoryComplete" ];
    run.executable = lib.getExe beets-import;
  };

  systemd.services.slskd = {
    serviceConfig = {
      # beets runs inside slskd and moves imports into the share.
      ReadOnlyPaths = lib.mkForce [ ];
      ReadWritePaths = [ music ];
    };
    # Without the mount, imports would land on the NVMe root.
    unitConfig.RequiresMountsFor = [ music ];
  };

  systemd.tmpfiles.settings.music.${music}.d = {
    user = "slskd";
    group = "slskd";
  };
}
