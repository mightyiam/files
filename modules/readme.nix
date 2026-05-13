let
  path_ = "README.md";
  text = # markdown
    ''
      In-repository file generation flake-parts module

      As Nix users, we naturally want
      the source of all truth to reside within Nix files 📜
      and other files that include that truth to be generated ⚡.

      For example, who didn't want to
      dynamically include various facts about their project
      in the readme and make sure those are up-to-date?

      but

      1. project repositories are expected to include _tracked_ readmes 📄

      2. Git tracked or not, `.gitignore` files must sometimes exist 🤷

      3. `.github/workflows/*` must be Git tracked (don't get me started on these)

      4. and the list goes on

      You may be thinking

      > Wait 🤔, so what if they must be tracked—I can still
      > generate them from Nix and then check that my repository is clean.

      And you'd be right!
      ...except that checking that your repository is clean cannot be a flake check.

      > Okay, so I'll make a flake check for each generated file.

      Well, yes, you could.
      ...or you could use this project—if you're using flake-parts, that is (sorry).
    '';
in
{
  perSystem =
    { pkgs, ... }:
    {
      files.files = [
        {
          inherit path_;
          drv = pkgs.writeText "README.md" text;
        }
      ];
    };
}
