{
  description = "nak, the nostr army knife";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      lib = nixpkgs.lib;
      forAllSystems = lib.genAttrs supportedSystems;
      version = "0-unstable";

      # Include only Go files in the CLI's package directories and its module manifests.
      goSources = directory:
        map (name: directory + "/${name}") (
          builtins.attrNames (
            lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".go" name) (
              builtins.readDir directory
            )
          )
        );
      src = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions (
          [ ./go.mod ./go.sum ] ++ lib.concatMap goSources [ ./. ./nostrfs ./nostrfs_cgo ]
        );
      };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          nak = pkgs.callPackage ./nix/package.nix {
            inherit src version;
          };
          default = nak;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              fish
              go_1_25
              gopls
              gotools
              just
            ];
          };
        }
      );

      nixosModules.default = import ./nix/module.nix self;
    };
}
