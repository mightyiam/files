{
  perSystem =
    { pkgs, ... }:
    {
      files.file."some-file.txt".source = pkgs.writeText "some-file.txt" "Some contents";
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
