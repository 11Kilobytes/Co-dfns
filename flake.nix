{
  outputs = inputs: {
    devShells.x86_64-linux.default = import ./shell.nix;
  };
}
