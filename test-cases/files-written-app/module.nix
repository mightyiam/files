{
  perSystem =
    psArgs@{ pkgs, ... }:
    {
      files = {
        writer = {
          exeFilename = "writer-app";
          app = true;
        };
        file = {
          "file-a.txt".text = ''
            with some contents
          '';
          "file-b".text = ''
            with some other contents
          '';
        };
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
