let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.11";
  pkgs = import nixpkgs {
    config =  {
      permittedInsecurePackages = ["freeimage-unstable-2021-11-01"]; # This is a dependency of nixpkgs.arrayfire
      allowUnfree = true; # For nixpkgs.dyalog
      packageOverrides = pkgs: {
        dyalog = pkgs.dyalog.override {
          acceptLicense = true;
        };
      };
    };
    overlays = [];
  };
in
pkgs.mkShell.override {
  stdenv = pkgs.stdenvAdapters.useMoldLinker pkgs.clangStdenv;
} {
  packages = with pkgs; [
    dyalog
    arrayfire
    nixd
    bear
    clang-tools
  ];
}
