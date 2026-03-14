.PHONY: all

all: labeled-object-states.pdf labeled-object-api-states.pdf

labeled-object-%.pdf: labeled-object-%.svg
	rsvg-convert -o $@ $<

labeled-object-%.svg: labeled-object-%.plantuml
	java -jar plantuml-1.2026.2.jar --svg $<
