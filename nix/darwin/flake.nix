{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
    let
      configuration = { pkgs, config, ... }: {

        nixpkgs.config.allowUnfree = true;

        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages =
          [
            pkgs.alacritty
            pkgs.neovim
            pkgs.mkalias
            pkgs.discord
          ];

        homebrew = {
          enable = true;
          brews = [
            "mas"
            "ripgrep"
            "lazygit"
            "sketchybar"
          ];
          casks = [
          "nikitabobko/tap/aerospace"
          ];
          masApps = {};
          onActivation = {
            cleanup = "zap";
            autoUpdate = true;
            upgrade = true;
          };
        };

        fonts = {
          packages = [
            (pkgs.nerdfonts.override {
              fonts = [ "JetBrainsMono" "Hack" ];
            })
          ];
        };

        # For making apps appear on spotlight search.
        system.activationScripts.applications.text =
          let
            env = pkgs.buildEnv {
              name = "system-applications";
              paths = config.environment.systemPackages;
              pathsToLink = "/Applications";
            };
          in
          pkgs.lib.mkForce ''
            # Set up applications.
            echo "setting up /Applications..." >&2
            rm -rf /Applications/Nix\ Apps
            mkdir -p /Applications/Nix\ Apps
            find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
            while read -r src; do
              app_name=$(basename "$src")
              echo "copying $src" >&2
              ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
            done
          '';

        system.defaults = {
          dock.autohide = true;
          dock.persistent-apps = [
            "${pkgs.alacritty}/Applications/Alacritty.app"
            "/Applications/DuckDuckGo.app"
          ];
          finder.FXPreferredViewStyle = "clmv";
          NSGlobalDomain.AppleICUForce24HourTime = true;
          NSGlobalDomain.AppleInterfaceStyle = "Dark";
          NSGlobalDomain.KeyRepeat = 2;
          NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
          NSGlobalDomain._HIHideMenuBar = true;
          trackpad.TrackpadRightClick = true;
          NSGlobalDomain."com.apple.trackpad.trackpadCornerClickBehavior" = 1; # right click
          universalaccess.reduceMotion = true;
        };
        system.keyboard = {
         enableKeyMapping = true;
         remapCapsLockToControl = true;
        };
        system.startup.chime = false;
        programs.zsh = {
           enable = true;
           enableBashCompletion = true;
           enableCompletion = true;
           enableSyntaxHighlighting = true;
           enableFzfCompletion = true;
           enableFzfHistory = true;
        };

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Enable alternative shell support in nix-darwin.
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Jonne-MacBook-Air
      darwinConfigurations."Jonne-MacBook-Air" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # User owning the Homebrew prefix
              user = "jonne";
            };
          }
        ];
      };
    };
}

