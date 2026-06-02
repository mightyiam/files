{
  perSystem =
    { pkgs, ... }:
    {
      packages.default =
        pkgs.writers.writeNuBin "script"
          # nu
          ''
            nix flake check
            touch $env.out
          '';
    };
}
