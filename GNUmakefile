MOCHA =		$(MOCHACMD) --compilers t.coffee:coffee-script
PEGJS =		$(PEGJSCMD)

MOCHACMD ?=	./node_modules/mocha/bin/mocha
PEGJSCMD ?=	./node_modules/pegjs/bin/pegjs

all: lib/routes-parser.js

check:
	npm test

bootstrap: npm-install all

npm-install:
	npm install

do-check:
	$(MOCHA) tests/*.t.coffee

lib/routes-parser.js: src/routes.pegjs
	$(PEGJS) $< $@

MAKEFLAGS =	--no-print-directory \
		--no-builtin-rules \
		--no-builtin-variables


.PHONY: all bootstrap check do-check npm-install

# vim: ts=8 noet sw=2 sts=2
