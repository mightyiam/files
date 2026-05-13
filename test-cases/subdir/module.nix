{
  perSystem =
    psArgs@{ pkgs, ... }:
    {
      files.files = [
        {
          path_ = "dir/file.txt";
          drv = pkgs.writeText "file-in-dir.txt" ''
            Contents match
          '';
        }
      ];
      packages = {
        writer = psArgs.config.files.writer.drv;

        default = pkgs.writeShellApplication {
          name = "script";
          text = ''
            ! nix flake check || { echo "succeeded unexpectedly"; exit 1; }
            nix run .#writer
            git add --intent-to-add .
            nix flake check
            declare out
            touch "$out" 
          '';
        };
      };
    };
}
