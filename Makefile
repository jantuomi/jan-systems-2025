.PHONY: all
all: clean linklog public_html public_gmi

.PHONY: linklog
linklog:
	./update-linklog-json.sh

public_html: check-post-dates linklog
	@echo "Building HTML..."
	unlink templates 2>/dev/null || true && ln -s templates_html templates
	zola build --force -o public_html
	unlink templates || true
	touch public_html

public_gmi: public_html
	@echo "Building Gemini..."
	unlink templates 2>/dev/null || true && ln -s templates_gmi templates
	zola build --force -o public_gmi
	unlink templates || true
	find public_gmi -type f -name '*.html' -exec sh -c \
		'for html do mv "$$html" "$${html%.html}.gmi"; done' sh {} +
	./convert_gmi_html.py public_gmi
	touch public_gmi

.PHONY: dev
dev:
	unlink templates || true
	ln -s templates_html templates
	@echo "Starting development server..."
	trap 'unlink templates || true' EXIT; zola serve --drafts

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
