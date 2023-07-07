{
  description = "Setup for PostgreSQL with Backups";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, treefmt-nix }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages."${system}";
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              ansible
              ansible-lint
              just
            ];
          };
        }
      );

      formatter = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages."${system}";
        in
        treefmt-nix.lib.mkWrapper
          pkgs
          {
            projectRootFile = "flake.nix";
            programs.nixpkgs-fmt.enable = true;
            programs.deadnix.enable = true;

            programs.yamlfmt.enable = true;
            programs.beautysh.enable = true;
          }
      );
    };
}
