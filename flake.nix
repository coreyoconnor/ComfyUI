{
    description = "AUTOMATIC1111/stable-diffusion-webui flake";

    inputs = {
        nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
        flake-utils.url = github:numtide/flake-utils;
    };

    outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem flake-utils.lib.defaultSystems (system: let
        pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
        };
    in rec {
        packages.default = throw "You need to specify which output you want: CPU, ROCm, or CUDA.";
        packages.cpu = import ./impl.nix { inherit pkgs; variant = "CPU"; };
        packages.cuda = import ./impl.nix { inherit pkgs; variant = "CUDA"; };
        packages.rocm = import ./impl.nix { inherit pkgs; variant = "ROCM"; };

        devShells.rocm = packages.rocm.overrideAttrs (oldAttrs: rec {
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath oldAttrs.buildInputs;
          LD_PRELOAD = "${pkgs.gperftools}/lib/libtcmalloc.so";
        });
    });
}
