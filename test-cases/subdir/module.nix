{
  perSystem =
    psArgs@{ pkgs, ... }:
    {
      files.file."dir/file.txt".text = ''
        Contents match
      '';
      packages = {
        writer = psArgs.config.files.writer.drv;

        default =
          pkgs.writers.writeNuBin "script"
            # nu
            ''
              use std/assert

              assert error { ^nix flake check }
              nix run .#writer
              git add --intent-to-add .
              nix flake check
              touch $env.out
            '';
      };
    };
}
