MOCHA =		mocha --compilers t.coffee:coffee-script
PEGJS =		pegjs

all: lib/routes-parser.js

check:
	npm test

do-check:
	$(MOCHA) tests/*.t.coffee

waves:
	./bin/ssnatch routes

lib/routes-parser.js: src/routes.pegjs
	$(PEGJS) $< $@

MAKEFLAGS =	--no-print-directory \
		--no-builtin-rules \
		--no-builtin-variables


.PHONY: all check do-check waves

# vim: ts=8 noet sw=2 sts=2
