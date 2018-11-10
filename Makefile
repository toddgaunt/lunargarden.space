# See LICENSE file for copyright and license details.

M4 = m4
M4FLAGS = --prefix-builtins --include=m4

SRC := wired.html.m4 \
       about.html.m4 \
       art.html.m4 \
       blog.html.m4 \
       programs.html.m4 \
       $(wildcard post/*/*.html.m4)
OBJ := $(patsubst %.html.m4, %.html, $(SRC))

# Standard targets
all: $(OBJ)
	@ln -sf blog.html index.html

options:
	@echo "Build options:"
	@echo "M4FLAGS  = $(M4FLAGS)"
	@echo "M4      = $(M4)"

dist: clean
	@printf -- "Creating dist tarball... "
	@tar -czf lunargarden.tar.gz $(SRC) m4/ css/ files/ res/ Makefile 404.html
	@echo "Done"

clean:
	@echo "Cleaning"
	@rm -f $(OBJ)
	@rm -f index.html

# Object Build Rules
%.html: %.html.m4 m4/site.m4
	@echo "M4 $@"
	@$(M4) $(M4FLAGS) $< > $@
	@tidy5 -q -i -w 80 -m $@

.PHONY: all options check clean dist
