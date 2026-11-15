{
  description = "touka-aoi's dotfiles (Home Manager)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      mkHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            # unfree ライセンスのパッケージは、ここに名前を挙げたものだけ許可する
            config.allowUnfreePredicate =
              pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "claude-code" ];
          };
          modules = [ ./home.nix ];
        };
    in
    {
      homeConfigurations = {
        # WSL (Ubuntu)
        "touka@wsl" = mkHome "x86_64-linux";
        # Mac (Apple Silicon)
        "touka@mac" = mkHome "aarch64-darwin";
      };
    };
}
