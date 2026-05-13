{ projectRoot, ... }:
{
  imports = [ ../flake-module.nix ];

  perSystem = psArgs: {
    treefmt = { inherit projectRoot; };
    files.gitToplevel = projectRoot;
    make-shells.default.packages = [ psArgs.config.files.writer.drv ];
  };
}
