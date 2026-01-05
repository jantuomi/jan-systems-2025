---
title: Deploying the garden
date: 2024-03-26
extra:
  kind: note
---

Every respectable tech blog must contain two posts:

- ”This site now has RSS”
- ”This is how this site is deployed”

Other content is optional.

## Writing on the go

Content updates go like this:

1. I write Markdown in a special directory in my Obsidian Vault
2. The change is synced to my Digital Ocean server via Obsidian Sync (I run an Obsidian process on my server)
3. A file system monitor script picks it up and runs a build script
4. Built HTML files are served with Nginx

This process gives me full control over the content wherever I have access to Obsidian. Making writing as easy as possible is the principle behind this design.

[This is considered a good idea in the frog community.](https://www.todepond.com/wikiblogarden/art/never-stop-writing/on-your-phone)

Making changes to the build process itself, or the HTML template, requires a computer, however.

## Parentheses

Most of the heavy lifting is done by `pandoc`. The glue parts use an obscure and ancient language with many curved sigils. Give it a try.

{{ fig(src="repo_langs.png", alt="A GitHub repository language breakdown showing that most of the code is written in Scheme.") }}

## Hosting

My small Digital Ocean server also moonlights as a container image registry. I build the scripts into an OCI image, push it on the server and run it with `docker-compose`. Don’t over-engineer when you want things _done_.
