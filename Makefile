# See LICENSE file for copyright and license details.

M4 = m4
M4FLAGS = --prefix-builtins --include=m4

SRC := about.html.m4 index.html.m4 art.html.m4 $(wildcard article/*.html.m4)
OBJ := $(patsubst %.html.m4, %.html, $(SRC))

# Standard targets
all: $(OBJ)

options:
	@echo "Build options:"
	@echo "M4FLAGS  = $(M4FLAGS)"
	@echo "M4      = $(M4)"

dist: clean

clean:
	@echo "Cleaning"
	@rm -rf $(OBJ)

# Object Build Rules
%.html: %.html.m4 m4/site.m4
	@echo "M4 $@"
	@$(M4) $(M4FLAGS) $< > $@
	#@tidy5 -m $@

.PHONY: all options check clean dist
