{
  description = "Tansanrao's dotfiles";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
        url = "github:LnL7/nix-darwin/nix-darwin-24.11";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin }: {

    darwinConfigurations."millennium-falcon" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ 
        home-manager.darwinModules.home-manager
        ./hosts/millennium-falcon/default.nix
      ];
    };

  };
}
