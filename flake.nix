{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, disko, ... }:
    {
      nixosConfigurations.daddy = nixpkgs.lib.nixosSystem {
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
          ./disko.nix
          ./users/soft.nix
          ./users/softer.nix
        ];
      };
    };
}
