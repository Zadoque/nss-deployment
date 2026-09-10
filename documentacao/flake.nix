{
  description = "Ambiente reprodutível para compilação da documentação do Núcleo de Situação de Saúde";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in {
      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          packages = [
            (pkgs.texlive.combine {
              inherit (pkgs.texlive)
                scheme-small
                babel-portuges
                booktabs
                enumitem
                etoolbox
                fancyhdr
                float
                geometry
                lastpage
                listings
                lmodern
                microtype
                setspace
                tcolorbox
                tools
                xcolor
                hyperref
                bookmark;
            })
          ];

          shellHook = ''
            echo "NSS Documentation"
            echo "  make pdf   - compila main.tex"
            echo "  make clean - remove artefatos temporarios"
          '';
        };
      });

      packages = forAllSystems ({ pkgs }:
        let
          tex = pkgs.texlive.combine {
            inherit (pkgs.texlive)
              scheme-small
              babel-portuges
              booktabs
              enumitem
              etoolbox
              fancyhdr
              float
              geometry
              lastpage
              listings
              lmodern
              microtype
              setspace
              tcolorbox
              tools
              xcolor
              hyperref
              bookmark;
          };
        in {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "nss-documentacao";
            version = "0.1.0";
            src = ./.;
            nativeBuildInputs = [ tex ];

            buildPhase = ''
              pdflatex -interaction=nonstopmode -halt-on-error main.tex
              pdflatex -interaction=nonstopmode -halt-on-error main.tex
            '';

            installPhase = ''
              mkdir -p $out
              cp main.pdf $out/
            '';
          };
        });

      apps = forAllSystems ({ pkgs }:
        let
          tex = pkgs.texlive.combine {
            inherit (pkgs.texlive)
              scheme-small
              babel-portuges
              booktabs
              enumitem
              etoolbox
              fancyhdr
              float
              geometry
              lastpage
              listings
              lmodern
              microtype
              setspace
              tcolorbox
              tools
              xcolor
              hyperref
              bookmark;
          };
          compile = pkgs.writeShellApplication {
            name = "compile-nss-documentacao";
            runtimeInputs = [ tex ];
            text = ''
              set -euo pipefail
              cd "$(dirname "$0")/.." 2>/dev/null || true
              pdflatex -interaction=nonstopmode -halt-on-error main.tex
              pdflatex -interaction=nonstopmode -halt-on-error main.tex
              echo "PDF gerado: main.pdf"
            '';
          };
        in {
          pdf = {
            type = "app";
            program = "${compile}/bin/compile-nss-documentacao";
          };
        });
    };
}
