{ projectRoot, ... }:
{
  imports = [ ../flake-module.nix ];

  perSystem = psArgs: {
    treefmt = { inherit projectRoot; };
    files = {
      gitToplevel = projectRoot;
      writer.app = true;
    };
    make-shells.default.packages = [ psArgs.config.files.writer.drv ];
  };
}
