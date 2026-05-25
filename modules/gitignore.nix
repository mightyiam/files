{ lib, config, ... }:
{
  options.gitignore = lib.mkOption {
    type = lib.types.lines;
    apply = text: text |> lib.splitString "\n" |> lib.naturalSort |> lib.concatStringsSep "\n";
  };
  config = {
    gitignore = "result";
    perSystem = {
      files.file.".gitignore".text = config.gitignore;
    };
  };
}
