{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # deploy: setup's CI advances it only once every host builds
    etrobert-setup.url = "github:etrobert/setup/deploy";
  };

  outputs =
    {
      nixpkgs,
      disko,
      etrobert-setup,
      ...
    }:
    {
      nixosConfigurations.daddy = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          etrobert-setup.nixosModules.draw
          ./configuration.nix
          ./disko.nix
          ./users/soft.nix
          ./users/softer.nix
          ./users/paal.nix
        ];
      };
    };
}
