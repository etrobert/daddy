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
      inputs.flake-parts.follows = "flake-parts";
      inputs.disko.follows = "disko";
    };
  };

  outputs =
    { nixpkgs, disko, ... }:
    {
      nixosConfigurations.daddy = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          disko-zfs.nixosModules.default
          ./configuration.nix
          ./disko.nix
          ./users/soft.nix
          ./users/softer.nix
        ];
      };
    };
}
