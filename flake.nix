{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  outputs = {
    self,
    nixpkgs,
  }: {
    devShells.x86_64-linux.default = import ./shell.nix {inherit nixpkgs;};
  };
}
