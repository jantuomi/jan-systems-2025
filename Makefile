# Templates require Zola 0.23.6+ (Tera 2); override with make ZOLA=/path/to/zola.
ZOLA ?= zola

.PHONY: all
all: clean linklog public_html public_gmi

.PHONY: linklog
linklog:
	./update-linklog-json.sh

public_html: check-post-dates linklog
	@echo "Building HTML..."
	@if [ -e templates ]; then \
		echo "Error: 'templates' link already exists, aborting."; \
		exit 1; \
	fi
	ln -s templates_html templates
	$(ZOLA) build --force -o public_html
	unlink templates || true
	touch public_html

public_gmi: public_html
	@echo "Building Gemini..."
	@if [ -e templates ]; then \
		echo "Error: 'templates' link already exists, aborting."; \
		exit 1; \
	fi
	ln -s templates_gmi templates
	$(ZOLA) build --force -o public_gmi
	unlink templates || true
	find public_gmi -type f -name '*.html' -exec sh -c \
		'for html do mv "$$html" "$${html%.html}.gmi"; done' sh {} +
	./convert_gmi_html.py public_gmi
	touch public_gmi

.PHONY: dev
dev:
	@if [ -e templates ]; then \
		echo "Error: 'templates' link already exists, aborting."; \
		exit 1; \
	fi
	ln -s templates_html templates
	@echo "Starting development server..."
	trap 'unlink templates || true' EXIT; $(ZOLA) serve --drafts

.PHONY: deploy
deploy: public_html public_gmi
	@echo "Deploying project..."
	rsync -rvzP --delete --chown 80:80 public_html/* $(RSYNC_TARGET_HTML)
	rsync -rvzP --delete --chown 80:80 public_gmi/*  $(RSYNC_TARGET_GMI)
	./send-webmentions.py

.PHONY: check-post-dates
check-post-dates:
	./check-post-dates.sh

.PHONY: clean
clean:
	@echo "Cleaning project..."
	unlink templates || true
	rm -rf public*
