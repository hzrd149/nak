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
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      version = "0-unstable-${builtins.substring 0 8 self.lastModifiedDate}";
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          nak = pkgs.callPackage ./nix/package.nix {
            inherit version;
            src = self;
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
