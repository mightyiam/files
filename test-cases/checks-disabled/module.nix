{
  perSystem =
    { pkgs, system, ... }:
    {
      files = {
        checks.enable = false;
        writer.app = true;
        file."some-file.txt".text = "Some contents";
      };
      checks.unrelated = pkgs.runCommand "unrelated-check" { } ''
        touch "$out"
      '';
      packages.default =
        pkgs.writers.writeNuBin "script"
          # nu
          ''
            use std/assert

            assert equal (nix eval --json .#checks.${system} --apply builtins.attrNames | from json) ["unrelated"]
            nix flake check
            assert (not ("some-file.txt" | path exists))
            nix run .#write-files
            assert equal (open --raw some-file.txt) "Some contents"
            touch $env.out
          '';
    };
}
