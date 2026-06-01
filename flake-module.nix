{
  flake-parts-lib,
  lib,
  self,
  ...
}:
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    psArgs@{ pkgs, ... }:
    let
      cfg = psArgs.config.files;
    in
    {
      options = {
        files = {
          gitToplevel = lib.mkOption {
            type = lib.types.path;
            default = self;
            defaultText = lib.literalExpression "self";
            description = ''
              Each check is performed by copying the existing file into the store
              and comparing its contents with the configured contents.

              For that purpose a path to the file must be provided to Nix.
              Configured file paths are relative to the Git top-level.
              But Nix is oblivious to the Git top-level.
              So file paths are resolved relative to the value of this option.

              The default value is correct when the flake is at the Git top-level.
              Otherwise the correct Git top-level must be provided.
            '';
            example = lib.literalExpression "../.";
          };

          file = lib.mkOption {
            description = ''
              Files to be written and checked for.
              The attribute name is the file path relative to Git top-level.
              Use slashes for subdirectories (e.g. `"diagrams/overview.md"`).
            '';
            default = { };
            example = lib.literalExpression ''
              {
                "README.md".text = "# My Project";
                ".gitignore".source = ./gitignore;
                "docs/guide.md".text = "...";
              }
            '';
            type = lib.types.lazyAttrsOf (
              lib.types.submodule (
                submoduleArgs@{ name, ... }:
                {
                  options = {
                    text = lib.mkOption {
                      type = lib.types.nullOr lib.types.lines;
                      default = null;
                      description = ''
                        Text content of the file.
                        Sets `source` automatically via `pkgs.writeText`.
                      '';
                    };
                    source = lib.mkOption {
                      type = lib.types.path;
                      description = ''
                        Path or derivation to use as the file content.
                        Is set automatically when `text` is provided.
                      '';
                    };
                  };
                  config.source = lib.mkIf (submoduleArgs.config.text != null) (
                    pkgs.writeText name submoduleArgs.config.text
                  );
                }
              )
            );
            apply =
              v:
              if cfg.files == null then
                v
              else
                throw ''
                  `perSystem.files.files` has been replaced with a more idiomatic API. Example:

                  ```nix
                  perSystem.files.file."docs/foo.md".text = "## contents";
                  ```
                '';
          };

          files = lib.mkOption {
            internal = true;
            type = lib.types.nullOr lib.types.unspecified;
            default = null;
          };

          writer = {
            filesJson = lib.mkOption {
              internal = true;
              type = lib.types.package;
              default = lib.pipe cfg.file [
                (lib.mapAttrsToList (
                  path:
                  { source, ... }:
                  {
                    inherit path source;
                  }
                ))
                (pkgs.writers.writeJSON "files.json")
              ];
            };
            exeFilename = lib.mkOption {
              type = lib.types.singleLineStr;
              default = "write-files";
              description = ''
                The writer executable filename.
              '';
              example = lib.literalExpression ''"files-write"'';
            };
            drv = lib.mkOption {
              description = ''
                Provides an executable
                that writes each configured file's contents to its path.
                Missing parent directories are created.

                Consider including this in the project's development shell.
              '';
              type = lib.types.package;
              readOnly = true;
            };
            app = lib.mkEnableOption "setting up as a flake app";
          };
        };
      };

      config = {
        files.writer.drv = pkgs.writeShellApplication {
          name = cfg.writer.exeFilename;
          runtimeInputs = [ pkgs.gitMinimal ];
          runtimeEnv.files = cfg.writer.filesJson;

          text =
            pkgs.writers.writeNu cfg.writer.exeFilename
              # nu
              ''
                cd (git rev-parse --show-toplevel)

                for file in (open $env.files) {
                  mkdir ($file.path | path dirname)
                  open --raw $file.source | save -f $file.path
                }
              '';

          derivationArgs = {
            allowSubstitutes = false;
            preferLocalBuild = true;
          };
        };

        checks = lib.flip lib.mapAttrs' cfg.file (
          path:
          { source, ... }:
          {
            name = "files/${path}";
            value =
              pkgs.runCommandLocal "flake-file-check"
                {
                  nativeBuildInputs = [ pkgs.difftastic ];
                  env = {
                    filePath = "${cfg.gitToplevel + "/${path}"}";
                    inherit source;
                  };
                }
                (
                  pkgs.writers.writeNu "flake-file-check"
                    # nu
                    ''
                      if not ($env.filePath | path exists) {
                        panic $"files: ($env.filePath) not found — consider running the files writer"
                      }

                      let type = $env.filePath | path type

                      if ($type != 'file') {
                        panic $"files: ($env.filePath) not a regular file, but a ($type)"
                      }

                      difft --exit-code --display inline $env.source $env.filePath
                      touch $env.out
                    ''
                );
          }
        );

        apps = lib.mkIf cfg.writer.app {
          ${cfg.writer.exeFilename} = {
            type = "app";
            program = lib.getExe cfg.writer.drv;
            meta.description = "Write all configured files to their paths";
          };
        };
      };
    }
  );
}
