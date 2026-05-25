{
  perSystem =
    { pkgs, ... }:
    {
      files.files = [ ];
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
