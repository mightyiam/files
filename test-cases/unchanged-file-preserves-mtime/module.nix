{
  perSystem =
    psArgs@{ pkgs, ... }:
    {
      files.file."a-file.txt".text = ''
        Contents muahahaha
      '';
      packages = {
        write-files = psArgs.config.files.writer.drv;

        default =
          pkgs.writers.writeNuBin "script"
            # nu
            ''
              let before = (ls a-file.txt | get 0.modified)

              nix run .#write-files

              if (open a-file.txt) != "Contents muahahaha\n" {
                error make { msg: "file content is wrong" }
              }

              let after = (ls a-file.txt | get 0.modified)

              if $before != $after {
                error make { msg: "mtime changed even though content was already up to date" }
              }

              touch $env.out
            '';
      };
    };
}
