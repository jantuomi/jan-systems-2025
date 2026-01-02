.PHONY: all
all:
	@echo "Building project..."
	./update-linklog-json.sh
	zola build

.PHONY: dev
dev:
	@echo "Starting development server..."
	./update-linklog-json.sh
	zola serve

.PHONY: deploy
deploy:
	@echo "Deploying project..."
	rsync -rvzP --delete --chown 80:80 out/* $(RSYNC_TARGET)

.PHONY: clean
clean:
	@echo "Cleaning project..."
	rm -rf public
