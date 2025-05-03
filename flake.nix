{
  description = "Flake packaging the wofi-ykman Bash script as a nix run app, and exposing a named overlay key";

  inputs = {
    nixpkgs = {url = "github:NixOS/nixpkgs";};
    flake-utils = {url = "github:numtide/flake-utils";};
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    defaultOverlay = final: prev: {
      wofi-ykman = prev.stdenv.mkDerivation {
        pname = "wofi-ykman";
        version = "1.0.0";

        src = self;
        dontBuild = true;

        buildInputs = with prev; [
          yubikey-manager
          wofi
          wl-clipboard
          wtype
          libnotify
        ];

        installPhase = ''
          mkdir -p $out/bin
          cp ${./wofi-ykman} $out/bin/wofi-ykman
          chmod +x $out/bin/wofi-ykman
        '';
      };
    };
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [defaultOverlay];
        };
      in {
        packages.wofi-ykman = pkgs.wofi-ykman;

        apps.wofi-ykman = flake-utils.lib.mkApp {
          drv = pkgs.wofi-ykman;
        };

        defaultPackage = pkgs.wofi-ykman;
        defaultApp = flake-utils.lib.mkApp {drv = pkgs.wofi-ykman;};
      }
    )
    // {overlays = {default = defaultOverlay;};};
}
