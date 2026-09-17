#!/bin/sh
# Checks that each post's filename date prefix matches its frontmatter date.
set -e

POSTS_DIR="${1:-content/posts}"
errors=0

for entry in "$POSTS_DIR"/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]-*; do
    [ -e "$entry" ] || continue

    basename=$(basename "$entry")
    filename_date="${basename%%-*}-${basename#*-}"
    filename_date="${basename:0:10}"

    if [ -d "$entry" ]; then
        md_file="$entry/index.md"
    else
        md_file="$entry"
    fi

    [ -f "$md_file" ] || continue

    frontmatter_date=$(grep -m1 '^date:' "$md_file" | awk '{print $2}')

    if [ "$filename_date" != "$frontmatter_date" ]; then
        echo "MISMATCH: $basename"
        echo "  filename: $filename_date"
        echo "  frontmatter: $frontmatter_date"
        errors=$((errors + 1))
    fi
done

if [ $errors -eq 0 ]; then
    echo "All post dates match."
fi

exit $errors
