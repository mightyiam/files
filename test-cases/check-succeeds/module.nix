{
  perSystem =
    { pkgs, system, ... }:
    {
      files.file."a-file.txt".text = ''
        Contents muahahaha
      '';
      packages.default =
        pkgs.writers.writeNuBin "script"
          # nu
          ''
            use std/assert

            assert equal (nix eval --json .#checks.${system} --apply builtins.attrNames | from json) ["files:a-file.txt"]
            nix flake check
            touch $env.out
          '';
    };
}
