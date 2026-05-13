{
  imports = [ ../../flake-module.nix ];

  perSystem = psArgs: {
    treefmt.projectRoot = ../..;
    files.gitToplevel = ../..;
    make-shells.default.packages = [ psArgs.config.files.writer.drv ];
  };
}
