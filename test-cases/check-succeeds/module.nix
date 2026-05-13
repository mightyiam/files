{
  perSystem =
    { pkgs, ... }:
    {
      files.files = [
        {
          path_ = "a-file.txt";
          drv = pkgs.writeText "a-file.txt" ''
            Contents muahahaha
          '';
        }
      ];
      packages.default = pkgs.writeShellApplication {
        name = "script";
        text = ''
          nix flake check
          declare out
          touch "$out" 
        '';
      };
    };
}
