{
  perSystem =
    { pkgs, ... }:
    {
      files.file."a-file.txt".text = ''
        Contents muahahaha
      '';
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
