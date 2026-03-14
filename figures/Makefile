.PHONY: all

all: fixup.pdf labeled-object-states.pdf labeled-object-api-states.pdf

fixup.pdf: fixup.gplt ../benchmark/fixup.txt
	gnuplot fixup.gplt

labeled-object-%.pdf: labeled-object-%.svg
	rsvg-convert -o $@ $<

labeled-object-%.svg: labeled-object-%.plantuml
	java -jar plantuml-1.2026.2.jar --svg $<
