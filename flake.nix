{
  nixConfig = {
    abort-on-warn = true;
    extra-experimental-features = [ "pipe-operators" ];
    allow-import-from-derivation = false;
  };

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      flake = false;
    };

    import-tree = {
      url = "github:vic/import-tree";
      flake = false;
    };

    make-shell = {
      url = "github:nicknovitski/make-shell";
      flake = false;
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    systems.url = "github:nix-systems/default";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs.projectRoot = ./.;
    } ((import inputs.import-tree) ./modules);
}
