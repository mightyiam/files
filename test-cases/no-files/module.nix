{
  perSystem =
    { pkgs, ... }:
    {
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
