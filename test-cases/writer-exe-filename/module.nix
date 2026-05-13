{
  perSystem =
    psArgs@{ pkgs, ... }:
    let
      path_ = "foo.txt";
    in
    {
      files = {
        writer.exeFilename = "write-files-please";
        files = [
          {
            inherit path_;
            drv = pkgs.writeText "foo.txt" ''
              Aey Ehs Dee Ehf
            '';
          }
        ];
      };
      packages = {
        writer = psArgs.config.files.writer.drv;

        default = pkgs.writeShellApplication {
          name = "script";
          text = ''
            nix build .#writer
            ./result/bin/write-files-please
            git add --intent-to-add ${path_}
            nix flake check
            declare out
            touch "$out" 
          '';
        };
      };
    };
}
