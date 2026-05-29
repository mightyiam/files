{
  perSystem =
    { pkgs, ... }:
    {
      files.files = [ ];
      packages.default =
        pkgs.writers.writeNuBin "script"
          # nu
          ''
            use std/assert

            assert error { ^nix flake check --print-build-logs }
            touch $env.out
          '';
    };
}
