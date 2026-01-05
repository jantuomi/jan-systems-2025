---
title: "A home server journey, part 1: Motivation"
date: 2025-06-30
description: |
  This is the first post in a blog series chronicling my progress with designing and setting up a new, physical FreeBSD home server.
extra:
  kind: note
---

This is the first post in a blog series chronicling my progress with designing and setting up a new, physical FreeBSD home server. I'm guessing this will become at least a three-parter, but that depends on how things actually go, and how in-depth I happen to write. This first part is about my motivations and requirements, whereas the latter ones will be more technical-deepdive-like.

{{ toc() }}

{{ fig(src="aliexpress_minipc.png", alt="A promotional image portraying the mini-PC I ended up getting") }}

## I need a place to run code and store files

I have pretty simple requirements for a server. I need to run a bunch of services, most of which are Node.js or Python apps, and serve some static websites and files. These are primarily personal applications: tracking finances, or keeping track of house chores, but also hobby projects that I host and expose to the world.

I also need to store files somewhere, like everyone that partakes in the modern digital society. There isn't that much data to store, really. I don't take that many photos or videos, which tend to be the main driver for purchasing more cloud storage, but I have some Ableton project files (music production) that take up some space. Currently all my project files fit in a couple dozen gigabytes. I store them alongside my documents in Google Drive, using a real-time Drive sync app. This does not include the audio samples and recordings in my projects: I would have to buy a restrictively expensive plan to store those in Drive.

I have a trusty Ubuntu server, chugging away in some rack in a DigitalOcean datacenter in Amsterdam. Even though DigitalOcean pricing is pretty reasonable for individuals in general, my monthly price tag is around ~35€, after taxes. That sum is based on the cost of running a medium sized x86-64 instance and storing some backup snapshots from that machine. Times twelve, that comes to around 420€ per year. To me, that is a sizeable amount of money.

{{ fig(src="do-june-billing.png", alt="DigitalOcean is charging $36.14 this month") }}

> 🤔 I would like to run a smaller instance, but I needed a certain level of RAM to reliably run Obsidian Sync. For whatever reason, less memory would have the app crash intermittently.

Having upgraded to instance to the current size, it is hard to downscale back to a smaller machine. It is possible, of course. But instead of doing that, I started to consider an alternative: maybe I could save some coins and get some hardware of my own, like in the prehistoric times, before cloud services became the de-facto way to run anything. With one year's cloud costs, I could surely get a capable small machine.

{{ fig(src="old-man-yells-at-cloud.png", alt="Old man yells at Cloud (FFVII)") }}

## Ownership and control

Money is not the only motivator. I dislike the idea of having the continuity of my digital presence rely on American / multinational corporations that have no real responsibility when it comes to ensuring my files stay intact, containers running and website up. Google could ban my account without batting an eyelid, which would directly make me lose access to my collection of personal photos, important documents, and various other files I prefer not lose. DigitalOcean could flag my server for suspicious activity.

All this isn't very likely, but it still happens. And even if it didn't, I don't like having a soulless, corporate entity being the arbitrator on whether I can access my own digital life or not. I would prefer to have the probability of an account-frozen catastrophe be exactly zero instead of 0.1%.

> 🤔 In terms of cloud provider trustworthiness, I think DigitalOcean is pretty high up in the rankings. I haven't seen much ire against them.🤔

I could provide these capabilities to myself, by managing my own hardware and networking. I could set up a NAS (network attached storage) box for the files, and run the services locally on either the same machine or some other hardware. It would have to be publicly accessible (Internet), just like my DigitalOcean VPS. It would have to provide _at least_ the same guarantees as the status quo: periodic restorable backups, redundant storage and at-rest encryption for stored files.

> As an alternative, I could move my stuff to a European, maybe even Finnish, company. There are some [shared hosting](https://en.wikipedia.org/wiki/Shared_web_hosting_service) providers that exist. I don't really consider this to be that good of an option. I feel that if I'm moving out of the public cloud, I might as well go all the way.

To replace something as generally trusted and widely used as Google Drive requires some proper thinking. I haven't previously set up any redundant disk storage. My systems have never followed the [3-2-1 backup rule](https://en.wikipedia.org/wiki/Backup#3-2-1_Backup_Rule).

{{ fig(src="3-2-1-Backup-Rule.png", alt="Maintain at least 3 copies of your data, keep 2 copies stored at separate locations, store at least 1 copy at an off-site location. Source: msp360.com") }}

Reaching for full ownership and control is not solely an objective aim. It is in part psychological, an attempt to get back control in a world of weakening privacy and walled content gardens. It is driven by emotion. And this is completely fine: humans are allowed to be motivated by emotion, especially when it comes to personal, hobby-adjacent things. To claim otherwise would be dishonest.

## Physical electronics are fun, tinkering is fun

There is an inherent value in physical things. People collect music on CDs, cassette tapes, and vinyls. Playing games on real hardware is seen differently from emulation. A computer running in my home is "more real" than a resource-sharing virtual machine in some datacenter.

It is nice to own, instead of rent. It is nice to not be bound by a contract, or a service agreement. Having fewer dependencies, legal or technical, is often favorable.

I can pick out the components and design the infrastructure for my system. I know the moving parts, I know that if something fails, one of the cogs in the machine has stopped turning. I then replace the cog. There is no mystery, at least in an [unknown-unknowns](https://en.wikipedia.org/wiki/There_are_unknown_unknowns) kind of way.

As long as things are not that serious, maintaining and administrating physical systems can be pretty fun.

## Simplicity begets reliability

Physical components are one thing, software is another. I have been running Ubuntu on the VPS for a long time, but I can think of multiple reasons to reconsider that choice.

When I picked Ubuntu years ago, I didn't know what kind of programs I would be running on the machine. I opted for a Linux distribution that is well supported and offers relatively recent versions of software. I was also uncertain about whether or not I would need to run graphical software. Ubuntu ships with `snap` and `flatpak` , both of which are used to run desktop apps. It is now clear to me that I don't need any of this; stable server software is all I need.

I am inspired by simplicity. I feel that systems are often improved by removing, not adding.

I don't understand what is going on in a Ubuntu installation. There are so many components that interact, it's hard to make sense of what affects what. There are sediment layers of Linux history in there, with some Canonical-added goodness in between. To be fair, I don't think I understand the inner workings of any Linux distribution, for that matter.

A friend had recently set up a bunch of machines using FreeBSD. The elegance of simplicity lures me in. FreeBSD is well respected when it comes to running stable server software. The system boots up with just a couple of processes running in `top`. The fantastic [FreeBSD handbook](https://docs.freebsd.org/en/books/handbook/) and supplementary reading by [Michael W. Lucas](https://mwl.io/nonfiction/os) directly teach what each file under `/etc/` does.

I did some more reading as well as some experimentation with a FreeBSD virtual machine. It quickly became clear that this should be the way forward. I am excited to try out new, but at the same time respected and old, technology.

FreeBSD is different. A familiar, but still strange system is fascinating. I have only worked with Linux systems before, so many things are as I expect them to be, while similarly many surprise me.

## To be continued

In the next part we'll dive into technical good stuff: setting up the machine and installing FreeBSD.
