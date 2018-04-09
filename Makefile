# disable implicit rules
.SUFFIXES:

SCAD_FILES = $(wildcard */*.scad)
STL_FILES = $(patsubst %.scad, %.stl, $(SCAD_FILES))

# create all stl files
.PHONY: all
all: $(STL_FILES)

# remove all stl files
.PHONY: clean
clean:
	rm $(STL_FILES)

# build stl files
%.stl: %.scad
	openscad $< -o $@

