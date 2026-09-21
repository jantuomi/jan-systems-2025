#!/usr/bin/env python3
"""Send webmentions via Telegraph for posts that opt in.

Parses public_html/posts/index.html for the list of post URLs, then
checks each post's HTML for u-category/u-syndication links. Skips pairs
already recorded in webmentions-sent.json (idempotency).

Requires: TELEGRAPH_TOKEN env var.
"""

import json
import os
import sys
from datetime import datetime, timezone
from html.parser import HTMLParser
from pathlib import Path
from urllib.error import HTTPError
from urllib.parse import urlencode, urljoin
from urllib.request import Request, urlopen

TELEGRAPH_ENDPOINT = "https://telegraph.p3k.io/webmention"
LOG_FILE = Path(__file__).parent / "webmentions-sent.json"
PUBLIC_DIR = Path(__file__).parent / "public_html"
BASE_URL = "https://jan.systems"

SYNDICATION_CLASSES = {"u-category", "u-syndication"}


class LinkCollector(HTMLParser):
    """Collect hrefs from <a> tags matching given CSS classes."""

    def __init__(self, match_classes: set[str] | None = None):
        super().__init__()
        self.match_classes = match_classes
        self.links: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple]) -> None:
        if tag != "a":
            return
        attr = dict(attrs)
        href = attr.get("href", "")
        classes = set(attr.get("class", "").split())
        if self.match_classes is None or classes & self.match_classes:
            if href:
                self.links.append(href)


def parse_links(html: str, match_classes: set[str] | None = None) -> list[str]:
    p = LinkCollector(match_classes)
    p.feed(html)
    return p.links


def post_urls_from_index() -> list[str]:
    index = (PUBLIC_DIR / "posts" / "index.html").read_text()
    links = parse_links(index)
    seen = set()
    urls = []
    for href in links:
        full = urljoin(BASE_URL + "/posts/", href)
        if full.startswith(BASE_URL + "/posts/") and full != BASE_URL + "/posts/":
            if full not in seen:
                seen.add(full)
                urls.append(full)
    return urls


def syndication_targets_for(post_url: str) -> list[str]:
    slug = post_url.rstrip("/").split("/")[-1]
    post_html_path = PUBLIC_DIR / "posts" / slug / "index.html"
    if not post_html_path.exists():
        return []
    html = post_html_path.read_text()
    return parse_links(html, match_classes=SYNDICATION_CLASSES)


def load_log() -> list[dict]:
    if LOG_FILE.exists():
        return json.loads(LOG_FILE.read_text())
    return []


def save_log(entries: list[dict]) -> None:
    LOG_FILE.write_text(json.dumps(entries, indent=2) + "\n")


def already_sent(log: list[dict], source: str, target: str) -> bool:
    return any(e["source"] == source and e["target"] == target for e in log)


def send_webmention(token: str, source: str, target: str) -> dict:
    data = urlencode({"token": token, "source": source, "target": target}).encode()
    req = Request(TELEGRAPH_ENDPOINT, data=data, method="POST")
    try:
        with urlopen(req) as resp:
            return json.loads(resp.read())
    except HTTPError as e:
        body = json.loads(e.read())
        print(f"  Error {e.code}: {body.get('error')} — {body.get('error_description')}", file=sys.stderr)
        return {}


def main() -> None:
    token = os.environ.get("TELEGRAPH_TOKEN")
    if not token:
        print("TELEGRAPH_TOKEN not set", file=sys.stderr)
        sys.exit(1)

    log = load_log()
    changed = False

    for post_url in post_urls_from_index():
        targets = syndication_targets_for(post_url)
        for target in targets:
            if already_sent(log, post_url, target):
                print(f"Already sent: {post_url} → {target}")
                continue

            print(f"Send webmention: {post_url} → {target}")
            answer = input("  Confirm? [y/N] ").strip().lower()
            if answer != "y":
                print("  Skipped.")
                continue
            result = send_webmention(token, post_url, target)
            if result.get("status") == "queued":
                log.append({
                    "source": post_url,
                    "target": target,
                    "telegraph_url": result.get("location"),
                    "sent_at": datetime.now(timezone.utc).isoformat(),
                })
                changed = True
                print(f"  Queued: {result.get('location')}")
            else:
                print(f"  Unexpected response: {result}", file=sys.stderr)

    if changed:
        save_log(log)
        print(f"\nLog updated: {LOG_FILE}")
    else:
        print("Nothing new to send.")


if __name__ == "__main__":
    main()
