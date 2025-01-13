{ pkgs, variant, ... }:

let
  hardware_deps = with pkgs;
    if variant == "CUDA" then [
      cudatoolkit
      linuxPackages.nvidia_x11
      xorg.libXi
      xorg.libXmu
      freeglut
      xorg.libXext
      xorg.libX11
      xorg.libXv
      xorg.libXrandr
      zlib
      # for xformers
      gcc
    ] else if variant == "ROCM" then [
      rocmPackages.rocm-runtime
      pciutils
    ] else if variant == "CPU" then [
    ] else throw "You need to specify which variant you want: CPU, ROCm, or CUDA.";

  buildInputs = with pkgs;
    hardware_deps ++ [
      coreutils
      gnugrep
      getconf
      gperftools
      libgcc
      git # The program instantly crashes if git is not present, even if everything is already downloaded
      python310
      stdenv.cc.cc.lib
      stdenv.cc
      ncurses5
      binutils
      gitRepo gnupg autoconf curl
      procps gnumake util-linux m4 gperf unzip
      libGLU libGL
      glib
      zstd
  ];

in
pkgs.stdenv.mkDerivation {
  inherit buildInputs;
  name = "stable-diffusion-webui-${variant}";
  src = ./.;

  lib = pkgs.lib.makeLibraryPath buildInputs;

  installPhase = ''
    mkdir -p $out/bin
    cp webui.sh $out/bin/
    chmod +x $out/bin/webui.sh
    mkdir -p $out/init-files
    cp -r ./* $out/init-files
  '';
}
