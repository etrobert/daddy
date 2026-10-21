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
    # deploy: setup's CI advances it only once every host builds
    etrobert-setup.url = "github:etrobert/setup/deploy";
  };

  outputs =
    {
      nixpkgs,
      disko,
      disko-zfs,
      etrobert-setup,
      ...
    }:
    {
      nixosConfigurations.daddy = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          disko-zfs.nixosModules.default
          etrobert-setup.nixosModules.draw
          ./configuration.nix
          ./disko.nix
          ./slskd.nix
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
