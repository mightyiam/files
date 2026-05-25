{
  perSystem =
    { pkgs, ... }:
    {
      files.file."some-file.txt".source = pkgs.writeText "some-file.txt" "Some contents";
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
