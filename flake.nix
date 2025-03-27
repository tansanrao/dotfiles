{
  description = "Home Manager configuration of tansanrao";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nix-darwin = {
        url = "github:LnL7/nix-darwin/nix-darwin-24.11";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-darwin, ... }:
    let
      # Common configuration for all systems
      username = "tansanrao";
    in {
      # Linux configuration 
      homeConfigurations."${username}" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix ];
        extraSpecialArgs = {
          inherit username;
          platform = "linux";
        };
      };

      # macOS configuration with nix-darwin
      darwinConfigurations."${username}-mac" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin"; # Use "x86_64-darwin" for Intel Macs
	specialArgs = { inherit username; };
        modules = [
          ./darwin-configuration.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = import ./home.nix;
            home-manager.extraSpecialArgs = {
              inherit username;
              platform = "darwin";
            };
          }
        ];
      };
  };
}
