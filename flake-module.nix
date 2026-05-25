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

          files = lib.mkOption {
            description = ''
              Files to be written and checked for.
            '';
            default = [ ];
            example =
              lib.literalExpression
                # nix
                ''
                  [
                    {
                      path = "README.md";
                      drv =
                        pkgs.writeText "README.md"
                          # markdown
                          '''
                            # Practical Project

                            Clear documentation
                          ''';
                    }
                    {
                      path = ".gitignore";
                      drv = pkgs.writeText "gitignore" '''
                        result
                      ''';
                    }
                  ]
                '';
            type = lib.types.listOf (
              lib.types.submodule (submoduleArgs: {
                options = {
                  path_ = lib.mkOption {
                    internal = true;
                    type = lib.types.unspecified;
                    default = null;
                  };
                  path = lib.mkOption {
                    type = lib.types.str;
                    description = ''
                      File path relative to Git top-level.
                    '';
                    example = lib.literalExpression ''".github/workflows/check.yaml"'';
                    apply =
                      v:
                      if submoduleArgs.config.path_ == null then
                        v
                      else
                        throw "the `path_` attribute has been renamed to `path`";
                  };
                  drv = lib.mkOption {
                    description = ''
                      Provide the file as a derivation.
                      The out path is expected to be a file.
                      Directory out path not supported;
                      pull request welcome!
                    '';
                    type = lib.types.package;
                    example =
                      lib.literalExpression
                        # nix
                        ''
                          pkgs.writers.writeJSON "gh-actions-workflow-check.yaml" {
                            on.push = { };
                            jobs.check = {
                              runs-on = "ubuntu-latest";
                              steps = [
                                { uses = "actions/checkout@v4"; }
                                { uses = "DeterminateSystems/nix-installer-action@main"; }
                                { uses = "DeterminateSystems/magic-nix-cache-action@main"; }
                                { run = "nix flake check"; }
                              ];
                            };
                          }
                        '';
                  };
                };
              })
            );
          };

          writer = {
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
          };
        };
      };

      config = {
        files.writer.drv = pkgs.writeShellApplication {
          name = psArgs.config.files.writer.exeFilename;
          runtimeInputs = [ pkgs.gitMinimal ];
          text = lib.pipe cfg.files [
            (map (
              { path, drv, ... }:
              ''
                dir=$(dirname ${path})
                mkdir -p "$dir"
                cat ${drv} > ${lib.escapeShellArg path}
              ''
            ))
            (lib.concat [
              ''
                toplevel="$(git rev-parse --show-toplevel)"
                cd "$toplevel"
              ''
            ])
            lib.concatLines
          ];

          derivationArgs = {
            allowSubstitutes = false;
            preferLocalBuild = true;
          };
        };

        checks = lib.pipe cfg.files [
          (map (
            { path, drv, ... }:
            {
              name = "files/${path}";
              value =
                let
                  file =
                    lib.pipe
                      [ cfg.gitToplevel "/" path ]
                      [
                        lib.concatStrings
                        lib.readFile
                        (pkgs.writeText "flake-files-file")
                      ];
                in
                pkgs.runCommandLocal "flake-file-check"
                  {
                    nativeBuildInputs = [ pkgs.difftastic ];
                  }
                  ''
                    difft --exit-code --display inline ${drv} ${file}
                    touch $out
                  '';
            }
          ))
          lib.listToAttrs
        ];
      };
    }
  );
}
