{
  description = "Danny's MacOS Nix Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile
          environment.systemPackages = [
            pkgs.neovim
            pkgs.rclone
            pkgs.gcc
            pkgs.clang-tools
            pkgs.cmake
            pkgs.ninja
            pkgs.nixfmt-rfc-style
            pkgs.nixd
          ];

          homebrew = {
            enable = true;
            brews = [
              "mas"
            ];
            casks = [
              "basictex"
            ];
            masApps = {
              Xcode = 497799835;
              OneDrive = 823766827;
              "Microsoft PowerPoint" = 462062816;
            };
          };

          environment.darwinConfig = "$HOME/.config/nix/flake.nix";

          fonts.packages = [
            pkgs.nerd-fonts.jetbrains-mono
            pkgs.nerd-fonts.caskaydia-cove
          ];

          # Auto upgrade nix packages and the daemon service
          services.nix-daemon.enable = true;

          # Enable flakes support in nix
          nix.settings.experimental-features = "nix-command flakes";

          # Set Git commit hash for darwin-version
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility
          system.stateVersion = 5;

          # Optional: Enable Fish shell
          # programs.fish.enable = true;

          # The platform he configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#silicon
      darwinConfigurations."silicon" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true; # Corrected 'True' to 'true'
              user = "dannykcw";

              # Declarative tap management
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
              };
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience
      darwinPackages = self.darwinConfigurations."silicon".pkgs;
    };
}
