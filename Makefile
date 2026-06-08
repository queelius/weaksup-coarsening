.PHONY: paper clean wordcount sim figures validation

PAPER = main

paper: $(PAPER).pdf

$(PAPER).pdf: $(PAPER).tex sections/*.tex refs.bib figures/rsweep_complexity.pdf
	pdflatex $(PAPER).tex
	bibtex $(PAPER)
	pdflatex $(PAPER).tex
	pdflatex $(PAPER).tex
	pdflatex $(PAPER).tex

sim: results.rds

results.rds: scripts/sim.R scripts/run.R
	Rscript scripts/run.R

figures: figures/identifiability_recovery.pdf figures/goldset_complexity.pdf \
         figures/rsweep_complexity.pdf

figures/identifiability_recovery.pdf figures/goldset_complexity.pdf: scripts/figures.R results.rds
	Rscript scripts/figures.R

# Idealized r-sweep validating the linear-in-r rate of T4. Self-contained
# (base R, no external data): runs the sweep and writes the figure directly.
figures/rsweep_complexity.pdf: scripts/rsweep_figure.R
	Rscript scripts/rsweep_figure.R

validation: results.rds figures

clean:
	rm -f $(PAPER).aux $(PAPER).bbl $(PAPER).blg $(PAPER).log \
	      $(PAPER).out $(PAPER).pdf $(PAPER).fdb_latexmk \
	      $(PAPER).fls $(PAPER).synctex.gz $(PAPER).toc \
	      sections/*.aux

wordcount:
	@texcount -inc -sum -1 $(PAPER).tex 2>/dev/null || \
	  echo "(install texcount for word count)"
