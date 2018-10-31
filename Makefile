# Authoritative build rules for tick.

# If you don't have GNU Make on your system, use this file as a
# cribsheet for how to build various aspects of tick.

STYLESDIR = ../asciidoctor-stylesheet-factory/stylesheets
STYLESHEET = juxt.css

.PHONY: 		watch default deploy test dev-doc-cljs

default:		docs/index.html

# Build the docs
docs/index.html:	docs/*.adoc docs/docinfo*.html ${STYLESDIR}/${STYLESHEET}
			asciidoctor -d book \
			-a "webfonts!" \
			-a stylesdir=../${STYLESDIR} \
			-a stylesheet=${STYLESHEET} \
			docs/index.adoc

test:
			clj -Atest -e deprecated
			rm -rf cljs-test-runner-out && mkdir -p cljs-test-runner-out/gen && clj -Sverbose -Atest-cljs 

# For developing the cljs used by the documentation, uses shadow-cljs
# See shadow-cljs.edn for configuration
dev-docs-cljs:
			npm i; shadow-cljs watch doc bootstrap-support

pom.xml:
			clj -Spom
# Dev pom is used to created development project with intellij
dev-pom:
			clj -R:dev:dev/rebel:dev/nrepl:test-cljs -C:dev:dev/rebel:dev/nrepl:test-cljs -Spom
			

deploy:			pom.xml
			mvn deploy
figwheel:
			clj -R:dev:dev/nrepl:dev/rebel -C:dev:dev/nrepl:dev/rebel:test -m figwheel.main -O whitespace --build-once tick
			
# hooray for stackoverflow			
.PHONY: list
list:
		@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs		

