#?
#? Makrocosm
#? ---------
#?

.PHONY: docs
docs: build/docs #? Build the documentation website to the directory build/docs

build/docs: mkdocs.yml $(shell find docs -iname '*.md')
	mkdocs build -d build/docs

#?

include rules.mk
