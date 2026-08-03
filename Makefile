.PHONY: all
all: clean
	@echo "Building project..."
	./update-linklog-json.sh

	# Build html
	ln -s templates_html templates
	zola build -o public_html
	unlink templates || true

	# Build gemini
	ln -s templates_gmi templates
	zola build -o public_gmi
	find public_gmi -type f -name '*.html' -exec sh -c \
		'for html do mv "$$html" "$${html%.html}.gmi"; done' sh {} +
	# Convert HTML blocks to gemtext
	./convert_gmi_html.py public_gmi
	unlink templates || true

.PHONY: dev
dev:
	@echo "Starting development server..."
	./update-linklog-json.sh
	ln -s templates_html templates
	zola serve --drafts

.PHONY: deploy
deploy:
	@echo "Deploying project..."
	rsync -rvzP --delete --chown 80:80 public_html/* $(RSYNC_TARGET_HTML)
	rsync -rvzP --delete --chown 80:80 public_gmi/*  $(RSYNC_TARGET_GMI)

.PHONY: clean
clean:
	@echo "Cleaning project..."
	unlink templates || true
	rm -rf public*
