{
  perSystem =
    psArgs@{ pkgs, ... }:
    {
      files.file."dir/file.txt".text = ''
        Contents match
      '';
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
