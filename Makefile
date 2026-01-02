.PHONY: all
all:
	@echo "Building project..."
	./update-linklog-json.sh
	zola build

dev:
	@echo "Starting development server..."
	./update-linklog-json.sh
	zola serve

.PHONY: clean
clean:
	@echo "Cleaning project..."
	rm -r public
