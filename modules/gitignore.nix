{ lib, config, ... }:
{
  options.gitignore = lib.mkOption {
    type = lib.types.lines;
    apply = text: text |> lib.splitString "\n" |> lib.naturalSort |> lib.concatStringsSep "\n";
  };
  config = {
    gitignore = "result";
    perSystem =
      { pkgs, ... }:
      {
        files.files = [
          {
            path_ = ".gitignore";
            drv = pkgs.writeText ".gitignore" config.gitignore;
          }
        ];
      };
  };
}
