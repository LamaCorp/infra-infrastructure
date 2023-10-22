{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    futils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, futils } @ inputs:
    let
      inherit (nixpkgs) lib;
      inherit (lib) recursiveUpdate;
      inherit (futils.lib) eachDefaultSystem defaultSystems;

      nixpkgsFor = lib.genAttrs defaultSystems (system: import nixpkgs {
        inherit system;
        config = {
          allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
            "terraform"
          ];
        };
      });
    in
    (eachDefaultSystem (system:
      let
        pkgs = nixpkgsFor.${system};
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            bgpq3
            go
            git
            jq
            openssl
            poetry
            pre-commit
            python3
            shellcheck
            terraform
            vault
          ];

          shellHook = ''
            source ./config.sh
          '';

          # See https://github.com/NixOS/nix/issues/318#issuecomment-52986702
          LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
        };
      }
    ));
}
