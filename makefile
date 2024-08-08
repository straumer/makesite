MAIN_LANG := $(shell ./bin/main_lang)
LANGS := $(shell ./bin/langs)
MACROS := $(shell ./bin/macro_paths $(LANGS))
SITE_TEMPLATES := $(shell [ -f templates/site.html ] && ./bin/site_template_paths $(LANGS))
HTML := $(shell ./bin/html_paths $(MAIN_LANG) $(LANGS))
STATIC_FILES := $(shell [ -d src ] && find src -type f | sed '/\(\.html\)$$/d; s/^src/dst/')
CONF := $(shell [ -f conf/general ] && echo conf/general)

all: $(MACROS) $(SITE_TEMPLATES) $(HTML) $(STATIC_FILES)

.SECONDEXPANSION:

-include gen/extra.mk

# Per language preprocessing

$(MACROS): gen/%.macros: conf/i18n/% macros/general $(CONF)
	cat macros/general $(CONF) $< > $@

$(SITE_TEMPLATES): gen/%.site.html: gen/%.macros templates/site.html macros/end
	./bin/indent templates/site.html | m4 -D ms_lang=$* -D ms_langs="$(LANGS)" $< macros/template macros/end - > $@


# Per target processing

$(HTML): %: $$(MAP_%) $$(if $(SITE_TEMPLATES),gen/$$(L_%).site.html) gen/$$(L_%).macros macros/content
	@mkdir -p $$(dirname $@)
	./bin/html $< $(L_$*) > $@

dst/%: src/%
	@mkdir -p $$(dirname $@)
	cp $< $@

clean:
	@rm -rf dst/* gen
