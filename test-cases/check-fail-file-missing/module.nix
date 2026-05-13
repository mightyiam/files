{
  perSystem =
    { pkgs, system, ... }:
    let
      path_ = "some-file.txt";
    in
    {
      files.files = [
        {
          inherit path_;
          drv = pkgs.writeText "some-file.txt" "";
        }
      ];
      packages.default = pkgs.writeShellApplication {
        name = "script";
        text = ''
          log=$(nix build '.#checks.${system}."files/${path_}"' --print-build-logs 2>&1 || true)
          substring="/some-file.txt"
          if [[ "$log" != *"$substring"* ]]; then
            echo "Substring \`$substring\` not found in log:"
            echo
            echo '```'
            echo "$log"
            echo '```'
            exit 1
          fi
          declare out
          touch "$out" 
        '';
      };
    };
}
