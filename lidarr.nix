# Lidarr from its develop branch, as only develop and nightly builds support
# plugins such as Tubifarry. Install those from System > Plugins.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  version = "3.2.0.5144";

  package = pkgs.stdenvNoCC.mkDerivation {
    pname = "lidarr-develop";
    inherit version;

    # nixpkgs builds master from source; develop would need its own lock files,
    # so this takes the prebuilt release instead.
    src = pkgs.fetchurl {
      url = "https://github.com/Lidarr/Lidarr/releases/download/v${version}/Lidarr.develop.${version}.linux-core-x64.tar.gz";
      sha256 = "09473b5ddc66dfe6350ae6aedcd7d4671b10465a91ac2471680364b9317fb7b0";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/lib/lidarr
      cp -r . $out/lib/lidarr/bin
      ln -sf ${pkgs.lib.getExe pkgs.chromaprint} $out/lib/lidarr/bin/fpcalc

      # Lidarr reads it from beside bin. Branch shows which updates the UI offers.
      cat > $out/lib/lidarr/package_info <<EOF
      PackageAuthor=etrobert/daddy
      PackageVersion=${version}
      Branch=develop
      UpdateMethod=External
      UpdateMethodMessage=Lidarr is managed by Nix. Update it in etrobert/daddy's lidarr.nix.
      EOF

      makeWrapper ${pkgs.dotnetCorePackages.aspnetcore_8_0}/bin/dotnet $out/bin/Lidarr \
        --add-flags $out/lib/lidarr/bin/Lidarr.dll \
        --prefix LD_LIBRARY_PATH : ${
          pkgs.lib.makeLibraryPath [
            pkgs.curl
            pkgs.icu
            pkgs.libmediainfo
            pkgs.openssl
            pkgs.sqlite
            pkgs.zlib
          ]
        }

      runHook postInstall
    '';
  };
in
{
  services.lidarr = {
    enable = true;
    inherit package;
  };

  # Installing or updating a plugin restarts Lidarr by exiting cleanly, which
  # on-failure would leave stopped.
  systemd.services.lidarr.serviceConfig.Restart = lib.mkForce "always";

  # /storage/music belongs to the users group, with setgid so new files stay in it.
  users.users.lidarr.extraGroups = [ "users" ];

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    config.services.lidarr.settings.server.port
  ];
}
