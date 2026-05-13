{
  perSystem =
    psArgs@{ pkgs, ... }:
    {
      files.files = [
        {
          path_ = "file-a.txt";
          drv = pkgs.writeText "file-a.txt" ''
            with some contents
          '';
        }
        {
          path_ = "file-b";
          drv = pkgs.writeText "file-b.txt" ''
            with some other contents
          '';
        }
      ];
      packages = {
        write-files = psArgs.config.files.writer.drv;

        default = pkgs.writeShellApplication {
          name = "script";
          text = ''
            nix run .#write-files
            git add --intent-to-add .
            nix flake check
            declare out
            touch "$out" 
          '';
        };
      };
    };
}
