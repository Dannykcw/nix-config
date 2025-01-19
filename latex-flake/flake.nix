{
  description = "LaTeX package flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # Set pkgs to the appropriate platform (e.g., aarch64-darwin)
        pkgs = nixpkgs.legacyPackages.${system};

        # Access texlive from nixpkgs
        texlivePackages = pkgs.texlive;

        # Import nixpkgs library
        lib = nixpkgs.lib;

        latexEnv =
          # Use TeX Live only for non-macOS systems
          if system == "aarch64-darwin" || system == "x86_64-darwin" then
            null # Skip installation for macOS, managed externally
          else
            texlivePackages.combined.scheme-basic; # Use TeX Live basic for other systems
      in
      {
        packages = rec {
          latexPackages = [
            latexEnv
            texlivePackages.latexmk
            texlivePackages.bibtex
          ];
        };
      }
    );
}
