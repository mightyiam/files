let
  path = ".github/workflows/check.yaml";
in
{
  perSystem =
    { pkgs, ... }:
    {
      files.files = [
        {
          inherit path;
          drv = pkgs.writers.writeJSON "gh-actions-workflow-check.yaml" {
            on = {
              push = { };
              workflow_call = { };
            };
            jobs.check = {
              runs-on = "ubuntu-latest";
              steps = [
                { uses = "actions/checkout@v4"; }
                {
                  uses = "nixbuild/nix-quick-install-action@master";
                  "with".nix_conf = ''
                    extra-experimental-features = recursive-nix
                    extra-system-features = recursive-nix
                    keep-env-derivations = true
                    keep-outputs = true
                  '';
                }
                {
                  uses = "nix-community/cache-nix-action@main";
                  "with".primary-key = "a-single-key";
                }
                { run = "nix flake --accept-flake-config check --print-build-logs"; }
              ];
            };
          };
        }
      ];
      treefmt.settings.global.excludes = [ path ];
    };
}
