{
  perSystem =
    { pkgs, ... }:
    let
      path = "some-file.txt";
    in
    {
      files.files = [
        {
          inherit path;
          drv = pkgs.writeText "some-file.txt" "";
        }
      ];
      packages.default = pkgs.writeShellApplication {
        name = "script";
        text = ''
          if nix flake check --print-build-logs; then
            exit 1
          fi
          declare out
          touch "$out" 
        '';
      };
    };
}
