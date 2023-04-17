{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    futils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, poetry2nix, futils } @ inputs:
    let
      inherit (nixpkgs) lib;
      inherit (lib) recursiveUpdate;
      inherit (futils.lib) eachDefaultSystem defaultSystems;

      nixpkgsFor = lib.genAttrs defaultSystems (system: import nixpkgs {
        inherit system;
        overlays = [ poetry2nix.overlay ];
      });
    in
    (eachDefaultSystem (system:
      let
        pkgs = nixpkgsFor.${system};
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (pkgs.poetry2nix.mkPoetryEnv {
              projectDir = self;

              overrides = pkgs.poetry2nix.overrides.withDefaults (self: super: {
                hvac = super.hvac.overridePythonAttrs (old: {
                  buildInputs = old.buildInputs ++ [ self.poetry ];
                });

                rfc3986-validator = super.rfc3986-validator.overridePythonAttrs (old: {
                  buildInputs = old.buildInputs ++ [ self.setuptools self.pytest-runner ];
                });
              });
            })
            bgpq3
            go
            git
            jq
            openssl
            poetry
            pre-commit
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
