# Note, GNU specific % used and envsubst

BASE_PAGES != [ -d src ] && find src -type f -name "*.html" | sed '/index\.html$$/d; s/\.html$$//g; s/^src/dst/g; s/.*/&\/index.html/g'
BASE_INDEX != [ -d src ] && find src -type f -name "index.html" | sed 's/^src/dst/g'
STATIC_FILES != [ -d src ] && find src -type f | sed '/\(\.html\)$$/d; s/^src/dst/'
LANGS != [ -d conf/i18n ] && ls conf/i18n
EXPLICIT_DEFAULT_LANG !=  printf '$(LANGS)' | sed -n '/_def$$/{p;q}'
DEFAULT_LANG != printf '$(LANGS)' | wc -w | sed 's/0/en/;s/1/$(LANGS)/;/^[^01]$$/s/.*/$(or $(EXPLICIT_DEFAULT_LANG),en)/'

PAGES = $(BASE_PAGES) $(call addlangprefixes,$(BASE_PAGES))
INDEX = $(BASE_INDEX) $(call addlangprefixes,$(BASE_INDEX))
CONFIGS != [ -d conf ] && find conf
TEMPLATES != [ -d templates ] && find templates

addlangprefixes = $(foreach lang,$(subst $(DEFAULT_LANG),,$(LANGS)),$(subst dst/,dst/$(lang)/,$(1)))
langprefix = $(findstring $(firstword $(strip $(subst /, ,$(1)))),$(LANGS))
rmlangprefix = $(subst /$(call langprefix,$(1))/,/,$(1))

all: $(PAGES) $(INDEX) $(STATIC_FILES)

.SECONDEXPANSION:

$(PAGES): dst%/index.html: src$$(call rmlangprefix,%).html $(CONFIGS) $(TEMPLATES)

$(INDEX): dst%index.html: src$$(call rmlangprefix,%)index.html $(CONFIGS) $(TEMPLATES)

%/index.html:
	./bin/html $< $@ '$(LANGS)' '$(DEFAULT_LANG)'

dst/%: src/%
	@mkdir -p $$(dirname $@)
	cp $< $@

deploy: all
	@. ./conf/general
	rsync --ignore-existing --delete-excluded -rvz $${rsync_from}/* $${rsync_to}

clean:
	@rm -r dst
