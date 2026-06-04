.PHONY: paper clean wordcount sim figures validation

PAPER = main

paper: $(PAPER).pdf

$(PAPER).pdf: $(PAPER).tex sections/*.tex refs.bib
	pdflatex $(PAPER).tex
	bibtex $(PAPER)
	pdflatex $(PAPER).tex
	pdflatex $(PAPER).tex
	pdflatex $(PAPER).tex

sim: results.rds

results.rds: scripts/sim.R scripts/run.R
	Rscript scripts/run.R

figures: figures/identifiability_recovery.pdf figures/goldset_complexity.pdf

figures/identifiability_recovery.pdf figures/goldset_complexity.pdf: scripts/figures.R results.rds
	Rscript scripts/figures.R

validation: results.rds figures

clean:
	rm -f $(PAPER).aux $(PAPER).bbl $(PAPER).blg $(PAPER).log \
	      $(PAPER).out $(PAPER).pdf $(PAPER).fdb_latexmk \
	      $(PAPER).fls $(PAPER).synctex.gz $(PAPER).toc \
	      sections/*.aux

wordcount:
	@texcount -inc -sum -1 $(PAPER).tex 2>/dev/null || \
	  echo "(install texcount for word count)"
