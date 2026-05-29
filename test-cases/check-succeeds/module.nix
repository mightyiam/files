{
  perSystem =
    { pkgs, ... }:
    {
      files.file."a-file.txt".text = ''
        Contents muahahaha
      '';
      packages.default =
        pkgs.writers.writeNuBin "script"
          # nu
          ''
            nix flake check
            touch $env.out
          '';
    };
}
