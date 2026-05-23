{
  flake.flakeModules.default = throw ''
    This flake is for development only. Please add `flake = false;` to your input
    and import as `"''${inputs.files}/flake-module.nix"`.
  '';
}
