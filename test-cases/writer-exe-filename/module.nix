{
  perSystem =
    psArgs@{ pkgs, ... }:
    let
      path = "foo.txt";
    in
    {
      files = {
        writer.exeFilename = "write-files-please";
        file.${path}.text = ''
          Aey Ehs Dee Ehf
        '';
      };
      packages = {
        writer = psArgs.config.files.writer.drv;

        default =
          pkgs.writers.writeNuBin "script"
            # nu
            ''
              nix build .#writer
              ./result/bin/write-files-please
              git add --intent-to-add ${path}
              nix flake check
              touch $env.out
            '';
      };
    };
}
