{
  lib,
  self,
  inputs,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    let
      testCasesDir = self + "/test-cases";
    in
    {
      treefmt.settings.global.excludes = [ "*.txt" ];

      checks =
        testCasesDir
        |> builtins.readDir
        |> lib.mapAttrs' (
          dirname: type:
          let
            flake =
              pkgs.writeText "test-case-${dirname}-flake.nix"
                # nix
                ''
                  {
                    inputs = {
                      files = {
                        url = "${../..}";
                        flake = false;
                      };
                      flake-parts = {
                        url = "${inputs.flake-parts}";
                        inputs.nixpkgs-lib.follows = "nixpkgs";
                      };
                      nixpkgs.url = "${inputs.nixpkgs}";
                      systems.url = "${inputs.systems}";
                    };
                    outputs =
                      inputs:
                      inputs.flake-parts.lib.mkFlake { inherit inputs; } {
                        systems = import inputs.systems;
                        imports = [
                          (inputs.files + "/flake-module.nix")
                          ./module.nix
                        ];
                      };
                  }
                '';
          in
          {
            name = "integration/${dirname}";
            value =
              pkgs.runCommand dirname
                {
                  nativeBuildInputs = [
                    pkgs.nix
                    pkgs.git
                  ];
                  requiredSystemFeatures = [ "recursive-nix" ];
                  env.NIX_CONFIG = ''
                    extra-experimental-features = nix-command flakes
                  '';
                }
                ''
                  set -o errexit
                  set -o nounset
                  set -o pipefail

                  export HOME="$(pwd)"

                  mkdir test-case
                  cd test-case
                  cp ${flake} flake.nix
                  cp -r ${testCasesDir + "/${dirname}"}/* .
                  git init .
                  git add .
                  git config user.name "test runner"
                  git config user.email "test@example.com"
                  git commit -m "some message"
                  nix run .
                '';
          }
        );
    };
}
