{
  perSystem =
    psArgs@{ pkgs, ... }:
    {
      files.file = {
        "file-a.txt".text = ''
          with some contents
        '';
        "file-b".text = ''
          with some other contents
        '';
      };
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
