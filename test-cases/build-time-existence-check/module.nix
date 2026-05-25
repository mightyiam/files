{
  perSystem =
    { pkgs, system, ... }:
    {
      files.file."some-file.txt".text = "";
      packages.default = pkgs.writeShellApplication {
        name = "script";
        text = ''
          nix eval '.#checks.${system}."files/some-file.txt"'

          if nix flake check --print-build-logs; then
            exit 1
          fi
          declare out
          touch "$out"
        '';
      };
    };
}
