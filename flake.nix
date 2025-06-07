{
  description = "Tansanrao's dotfiles";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
        url = "github:LnL7/nix-darwin/nix-darwin-25.05";
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

    homeConfigurations."tansanrao@death-star" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./hosts/death-star/default.nix ];
    };
    
    homeConfigurations."tansanrao@x-wing" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./hosts/x-wing/default.nix ];
    };

    homeConfigurations."tansanrao@wukong7" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./hosts/lab-servers/default.nix ];
    };

  };
}
