{ config, pkgs, ... }:
let
  python = pkgs.python3.withPackages (ps: [
    ps.music-tag
    ps.pyarr
    ps.requests
    # Not in nixpkgs.
    (ps.buildPythonPackage rec {
      pname = "slskd_api";
      version = "0.1.5";
      format = "wheel";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/py3/s/slskd_api/slskd_api-${version}-py3-none-any.whl";
        hash = "sha256-3gPCGgtfK2MW+NvycMaFkIW/VS6B7WAkqxkvUdRWpMA=";
      };
      dependencies = [ ps.requests ];
    })
  ]);

  soularr = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/mrusse/soularr/v1.2.3/soularr.py";
    hash = "sha256-1j3sXejL4bPf7J4L5iI8XUZW6jDwIiR6Vjk7Ple7398=";
  };
in
{
  systemd.services.soularr = {
    # Disabled for now.
    enable = false;
    description = "Download Lidarr's wanted albums through slskd";
    after = [
      "network-online.target"
      "slskd.service"
    ];
    wants = [ "network-online.target" ];
    startAt = "*:0/5";

    # Holds the Lidarr and slskd API keys, so it is placed by hand.
    unitConfig.ConditionPathExists = "/etc/soularr.ini";

    serviceConfig = {
      Type = "oneshot";
      # Soularr moves and deletes files in slskd's download directory.
      User = config.services.slskd.user;
      Group = config.services.slskd.group;
      StateDirectory = "soularr";
      LoadCredential = "config.ini:/etc/soularr.ini";
      # No lock file: a crash would leave it behind and block every later run,
      # and systemd already prevents overlapping runs.
      ExecStart = "${python}/bin/python ${soularr} --no-lock-file --config-dir \${CREDENTIALS_DIRECTORY} --var-dir /var/lib/soularr";
    };
  };
}
