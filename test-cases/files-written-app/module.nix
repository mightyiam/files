{
  perSystem =
    psArgs@{ pkgs, ... }:
    {
      files = {
        writer = {
          exeFilename = "writer-app";
          app = true;
        };
        files = [
          {
            path = "file-a.txt";
            drv = pkgs.writeText "file-a.txt" ''
              with some contents
            '';
          }
          {
            path = "file-b";
            drv = pkgs.writeText "file-b.txt" ''
              with some other contents
            '';
          }
        ];
      };
      packages = {
        write-files = psArgs.config.files.writer.drv;

        default = pkgs.writeShellApplication {
          name = "script";
          text = ''
            nix run .#writer-app
            git add --intent-to-add .
            nix flake check
            declare out
            touch "$out"
          '';
        };
      };
    };
}
