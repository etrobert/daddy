{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko-zfs = {
      url = "github:numtide/disko-zfs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # deploy: setup's CI advances it only once every host builds
    etrobert-setup.url = "github:etrobert/setup/deploy";
  };

  outputs =
    {
      nixpkgs,
      disko,
      disko-zfs,
      sops-nix,
      etrobert-setup,
      ...
    }:
    {
      nixosConfigurations.daddy = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          disko-zfs.nixosModules.default
          sops-nix.nixosModules.sops
          etrobert-setup.inputs.agenix.nixosModules.default
          etrobert-setup.nixosModules.ports
          etrobert-setup.nixosModules.draw
          etrobert-setup.nixosModules.countdown
          etrobert-setup.nixosModules.nutricalc
          etrobert-setup.nixosModules.creatures
          etrobert-setup.nixosModules.rift-radar
          etrobert-setup.nixosModules.umami
          ./configuration.nix
          ./disko.nix
          ./lidarr.nix
          ./navidrome.nix
          (import ./user-container.nix {
            name = "paal";
            subnet = 2;
            user = ./users/paal.nix;
            bindMounts = {
              "/storage/music".isReadOnly = false;
              "/storage/downloads" = { };
              "/var/lib/slskd/downloads" = { };
            };
            # A device on Paal's FRITZ!Box, with the address it handed out.
            wireguard = {
              address = "192.168.10.203/32";
              endpoint = "9qo5i95uzvrcwy37.myfritz.net:57867";
              publicKey = "mqotR4eXHsRQIWu/4Ue2nkC2ASYx0fRhlZHkqno4/AA=";
              # Only his home network, not everything as the FRITZ!Box suggests.
              allowedIPs = [ "192.168.10.0/24" ];
            };
          })
          ./peira.nix
          ./slskd.nix
          ./transmission.nix
          ./users/soft.nix
          ./users/softer.nix
          ./users/paal.nix
        ];
      };

      formatter = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );
    };
}
