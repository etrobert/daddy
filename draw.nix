{ pkgs, ... }:
{
  services.caddy = {
    enable = true;
    openFirewall = true;
    virtualHosts."draw.etiennerobert.com".extraConfig = /* caddy */ ''
      root * ${pkgs.callPackage ./excalidraw.nix { }}
      encode zstd gzip
      try_files {path} /index.html
      file_server
    '';
  };
}
