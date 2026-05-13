let
  path_ = ".github/workflows/check.yaml";
in
{
  perSystem =
    { pkgs, ... }:
    {
      files.files = [
        {
          inherit path_;
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
                  uses = "DeterminateSystems/nix-installer-action@main";
                  "with".extra-conf = ''
                    extra-experimental-features = recursive-nix
                    extra-system-features = recursive-nix
                  '';
                }
                { uses = "DeterminateSystems/magic-nix-cache-action@main"; }
                { run = "nix flake --accept-flake-config check --print-build-logs"; }
              ];
            };
          };
        }
      ];
      treefmt.settings.global.excludes = [ path_ ];
    };
}
