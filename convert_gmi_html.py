#!/usr/bin/env python3
"""Convert HTML blocks in .gmi files to gemtext using html2gmi."""

import html
import subprocess
import sys
from pathlib import Path

START_MARKER = "<!-- START_GEMINI_CONTENT -->"
END_MARKER = "<!-- END_GEMINI_CONTENT -->"
HTML2GMI = Path.home() / "go/bin/html2gmi"


def convert_file(path: Path) -> None:
    content = path.read_text()
    result = []
    pos = 0

    while True:
        start = content.find(START_MARKER, pos)
        if start == -1:
            result.append(content[pos:])
            break

        end = content.find(END_MARKER, start)
        if end == -1:
            result.append(content[pos:])
            break

        # Add content before the marker
        result.append(content[pos:start])

        # Convert HTML block to gemtext
        html_content = content[start + len(START_MARKER):end]
        converted = subprocess.run(
            [HTML2GMI],
            input=html_content,
            capture_output=True,
            text=True,
        )
        result.append(converted.stdout)

        pos = end + len(END_MARKER)

    # Unescape HTML entities in the entire file
    path.write_text(html.unescape("".join(result)))


def main() -> None:
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <directory>", file=sys.stderr)
        sys.exit(1)

    directory = Path(sys.argv[1])
    for path in directory.rglob("*.gmi"):
        convert_file(path)


if __name__ == "__main__":
    main()
