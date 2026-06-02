{
  perSystem =
    { pkgs, system, ... }:
    {
      files.file."some-file.txt".text = "";
      packages.default =
        pkgs.writers.writeNuBin "script"
          # nu
          ''
            use std/assert

            nix eval '.#checks.${system}."files/some-file.txt"'
            assert error { ^nix flake check --print-build-logs }
            touch $env.out
          '';
    };
}
