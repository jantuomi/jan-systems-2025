---
title: jan.systems tech stack retro/prospective
date: 2025-04-28
extra:
  kind: note
---

I have a website authoring system that involves Obsidian sync and a hand-crafted static site generator (SSG) [written in Scheme](/posts/deploying-the-garden) that:

- syncs Markdown files to my VPS
- compiles Markdown source files into HTML pages using pandoc
- parses and processes Markdown frontmatter as metadata
- builds an RSS feed from the pages
- builds the blog archive page that shows a time-sorted list of blog posts
- builds the `/now` page based on the most recent post with frontmatter binding `type: now`
- copies the compilation artifacts and static files to the web server directory

### I have a couple of qualms with this setup

- Running Obsidian Sync requires a graphical X environment, as Obsidian is a GUI app
  - I have successfully used [xpra](https://xpra.org/index.html) for this, since my VPS seems to have X installed (why, I'll never know). A properly headless server could use [xvfb](https://www.x.org/releases/X11R7.6/doc/man/man1/Xvfb.1.xhtml)
- Refactoring scheme source code to weave new data through the compilation pipeline is kind of rough, and makes me long for static typing
- A full build is slow (several seconds), mainly because of pandoc, but also because of interpreted scheme
- A change in one file triggers a full build, since the build system does not understand incremental builds.
- Pandoc handles inline HTML in a very weird way when using specific tags. I have not looked into why. This makes writing HTML-infused Markdown very fragile since I have to constantly manually inspect the output HTML for quirks.
- Pandoc is very heavy in terms of disk space (I have a small VPS SSD)
- When making edits, CPU usage on the VPS easily jumps to over 50%

### The good parts

It works pretty well. There as some small issues here and there, but it works.

### New feature: linklog

I would like to add a new feature: rendering recent links from [my linkhut profile](https://ln.ht/~jant) on the `/liked` page (possibly to be renamed to `/linklog` or something). Adding this to the current setup is possible. Linkhut has a JSON API for this use case, so I would only have to 1) parse the JSON, and 2) render a HTML fragment.

### Approach

In the light of my [most recent post](/posts/pile-of-incomplete-projects) I should fight the urge to rewrite the thing in Rust. However, I really want to get rid of pandoc.

As such, I will probably RiiR at some point, using a [markdown library](https://github.com/wooorm/markdown-rs) instead of pandoc.
