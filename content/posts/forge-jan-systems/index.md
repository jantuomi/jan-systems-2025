---
title: I migrated my repos to my home server – forge.jan.systems
description: |
  All my projects in GitHub and GitLab have been migrated and will be developed in the "forge" from here on out.
date: 2026-08-23
extra:
  kind: post
---

Check out my new, self-hosted Git server: [forge.jan.systems](https://forge.jan.systems)

It is now my primary Git remote. All my projects in GitHub and GitLab have been migrated and will be developed in the "forge" from here on out. 

## Why?

Piece by piece, I'm moving my personal computing out of the hands of American tech giants. I want to self-host where it makes sense, and use European services where it doesn't.

Hosting my own Git server is pain free and gives me control over my data.

The current, working iteration consists of two parts: a [cgit](https://git.zx2c4.com/cgit/about/) based, heavily customized web UI for browsing, and a `ssh`-based interface for management.

There are no collaboration features. You can email me a link to your fork if you want to request a merge. I track issues on pen & paper.

There is no CI/CD. I don't really see the point for pipelines in personal projects. A `Makefile` and some Git hooks together often create a comfortable level of automation and immediacy.

{{ fig(src="forge-cgit.png", alt="The diddle project, as seen in the forge.") }}


## Management TUI

My solution is heavily inspired by [William Brawner's blog post](https://wbrawner.com/2019/02/16/a-simple-self-hosted-git-server/), go read it.

{{ fig(src="forge-tui.png", alt="A screen capture of the TUI, showing help text and ls output.") }}

I can do basic CRUD operations on repositories using this interface. It also let's me set up mirrors in either direction. Currently I have set up mirrors for most of my GitHub and GitLab repos, so that the repos are still accessible where they were originally created.

I'm still debating if I should delete the repos fully from those platforms.
