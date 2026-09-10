.PHONY: pdf clean

pdf:
	pdflatex -interaction=nonstopmode -halt-on-error main.tex
	pdflatex -interaction=nonstopmode -halt-on-error main.tex

clean:
	rm -f main.aux main.log main.out main.toc main.fls main.fdb_latexmk main.synctex.gz main.pdf
	rm -f *.aux *.log *.out *.toc *.fls *.fdb_latexmk *.synctex.gz
