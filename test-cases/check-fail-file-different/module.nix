{
  perSystem =
    { pkgs, ... }:
    {
      files.files = [
        {
          path_ = "some-file.txt";
          drv = pkgs.writeText "some-file.txt" "Some contents";
        }
      ];
      packages.default = pkgs.writeShellApplication {
        name = "script";
        text = ''
          log=$(nix flake check --print-build-logs 2>&1 || true)
          substring="This is obviously different"
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
