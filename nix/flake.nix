{
  description = "Gerris nix-darwin system flake";
  # TODO: Figure out how to setup android tools using
  # https://github.com/tadfisher/android-nixpkgs?tab=readme-ov-file

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {
      #services.nix-daemon.enable = true;
      nix.enable = true;
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [ 
        pkgs.vim
        pkgs.jdk17
        pkgs.kotlin
        pkgs.alacritty
        pkgs.mkalias
        pkgs.alt-tab-macos
        pkgs.localsend
        pkgs.inetutils
        pkgs.wget
        pkgs.scrcpy
        pkgs.tmux
        pkgs.neovim
        pkgs.ripgrep
        pkgs.tree
      ];

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      security.pam.services.sudo_local.touchIdAuth = true;
      system.activationScripts.applications.text = let
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
        dock.orientation = "bottom";
        dock.autohide = true;
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled = false;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      homebrew.enable = true;
      homebrew.casks = [
        "android-commandlinetools"
        "jetbrains-toolbox"
        "monitorcontrol"
        "ghostty"
      ];

      homebrew.taps = [
        "leoafarias/fvm"
      ];

      homebrew.brews = [
        "fvm"
      ];

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      nixpkgs.config.allowUnfree = true;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."air15" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
      ];
    };

    darwinPackages = self.darwinConfigurations."air15".pkgs;
  };
}
