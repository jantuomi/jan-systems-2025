---
title: "EuroBSDCon 2026: conference notes"
date: 2026-09-17
slug: eurobsdcon-2026-conf-notes
description: EuroBSDCon 2026 took place in Brussels, Belgium. Here are my impressions from the event, top three talks, and travel notes.
extra:
  kind: note
  indienews: true
---

{{ toc() }}

{{ fig(src="atomium.jpeg",alt="The Atomium, an educational and cultural landmark in Brussels.") }}

## EuroBSDCon 2026

[EuroBSDCon](https://eurobsdcon.org) is one of the events organized under the BSD community umbrella, focusing on all things related to and descending from 4.4 Berkeley Software Distribution. This year's event was held between September 9th and 13th in Brussels, Belgium, but the city and country change every year.

The themes revolved around BSD (naturally), but there's always a healthy serving of generalizable talk about e.g. networking, filesystems, infosec, reliability, and of course AI/LLMs (unavoidable).

I've been mostly interested in reliability and disaster recovery themes this year. I've been especially thinking a lot about [ZFS](https://openzfs.org/wiki/Main_Page) and its role in storage systems and backups. Fortunately, I got some really useful takeaways from a couple of talks regarding those subjects, especially from Stefano's talk (outlined below), which I can apply in my work and [FreeBSD](https://www.freebsd.org) homelab administration as well.

I attended the event for three days: one day for _tutorials_ (i.e. workshops or labs) and two days for the talks. The days were long, so I was always pretty gassed in the evenings. It didn't help that I'm still recovering from an elbow fracture; some things are pretty difficult for me to do right now, and I get fatigued faster.

I enjoyed the content a lot, regardless of my general weariness. I was constantly learning something new. There was always an interesting talk to attend, or knowledgeable people to talk to.

I'm glad I always had my little A7 notebook at the ready; I was constantly taking notes.

The level of expertise present at the con was staggering. Seeing the number of kernel developers and Berkeley professors in the room you'd assume that everyone there was some kind of top expert (may be true?). The radiating enthusiasm for technology was infectious.

## Tutorials

### Managing FreeBSD jails with Sylve and Ansible (by Patrick M. Hausen)

The session introduced [Sylve](https://sylve.io) as a new tool for managing a FreeBSD server fleet. It is pretty much like Proxmox, but with first class support for features such as jails, vnet networking and ZFS.

The session was very hands on. We set up a virtual machine on our laptops and used [Ansible](https://docs.ansible.com/projects/ansible/latest/index.html) to provision a Sylve instance on the vm. Sylve was then used through its web GUI to run a network-reachable service jail.

I have to say that the tool looks sleek and well thought out. However, I will personally stick to my Ansible playbooks and other infrastructure-as-code (IaC) approaches over click-ops administration. If Sylve gets a convenient API, I would consider using it via IaC tools, to benefit from things like transferrable jails/vms between FreeBSD hosts.

I hope they find success with the project.

### FreeBSD Ports Any% Speedrun 180min (by Mateusz Piotrowski)

This workshop was all about demystifying the FreeBSD ports framework with some theory and a some hands-on exercises.

We learned about the ports framework, i.e. the system for making arbitrary software installable on FreeBSD, from the perspectives of the user, the port maintainer, and the framework developer.

I got answers to a number or questions that had been bugging me about the port patching process. I also got my own account set up on the FreeBSD Bugzilla; I'm ready to submit some of my ports!

{{ fig(src="recharging.jpeg", alt="Me recharging outside the venue after a full day of talks. Photo credit: Oks4@Libera.Chat") }}

## My top three talks

### The night 142 of my servers went up in the clouds. Physically. (by Stefano Marinelli)

Watch online on [exquisite.tube](https://exquisite.tube/w/nQbc54t4G7YGaqiryZ7mg1).

Stefano recounted the tale of a night when a datacenter has suffered a disasterous fire, irreparably destroying a large number of their virtual servers. Many of these servers were used in customer work, and their nonexistence would mean loss of service for multiple customers. Stefano had to recover a variety of backups to set up new servers in different datacenters (and on different providers) and recover connectivity.

The talk was presented in a post-mortem timeline format. The steps taken and the problems encountered gave insight to how I could approach the situation, if something similar were to happen to me.

Stefano shared good tips about DNS setup, reduced provider VPS supply in times of disaster (a lot of buying pressure from new customers), and monitoring.

**Takeaways**:

- Set up monitoring so that a disaster won't flood your channels with undebuggable alerts. Critical alerts should optimally be concise and help you get to the root of the issue as soon as possible.
- Test your backups periodically. In Stefano's case, there were backups of wrong filesystems 😬. Luckily, they had multiple levels of backups, and they were able to restore the system from a less recent, slower backup.
- Prefer ZFS send-receive backups if available.

### Looney Tunes: FreeBSD, rsync, and ZFS (by Mateusz Piotrowski)

Watch online on [exquisite.tube](https://exquisite.tube/w/wM3BGgDRvVypaEEyGA8aF4).

Mateusz described a tricky situation where a routine rsync job was pegging the CPU for no apparent reason, causing notable I/O performance losses. They went down the rabbit hole and discovered that the ZFS cache (ARC) was aggressively trying to prune resources that the rsync job was creating more at the same time, causing a tug-of-war situation that did not resolve on its own.

By following leads and analyzing some ZFS tunables (numeric settings) they were able to tune ZFS in a way that stopped the incessant prune jobs and made the rsync perform as expected.

**Takeaways**:

- Measure first and last.
- Apart from CPU%, mem, and I/O monitoring, monitor also filesystem locks, queues etc.

### rcd(8): modern service manager the FreeBSD way (by Baptiste Daroussin aka bapt)

Watch online on [exquisite.tube](https://exquisite.tube/w/nPGJ2TbJ8kzP8SHXiwzirU).

Baptiste has been designing a new service manager to replace the currently used `rcNG` in FreeBSD. The `rcNG` uses a rather simple system of shell scripts and config files to start up services sequentially, but does not readily support things like health checks or automatic restarts. There features are popular in e.g. SystemD, so the new `rcd` system would bring these to FreeBSD while still being `rc`-like in spirit.

The system is now in review, and if it gets merged, it will be supported beside `rcNG`. There is no intention to enforce a migration schedule to the new system for those that prefer to stick to the current system.

**Takeaways**:

- It is possible to rethink core components that have been there in the OS since the very early days.

## Free time in the city

I had some time on my arrival day and during evenings to walk around the city center and see some sights. Since I was not at my regular capacity in terms of health and energy, I made a very compact list of things to see and try during the trip.

{{ fig(src="volauvent.jpeg", alt="Vol-au-vent and Leffe Blonde at Brasserie du Primrose") }}

On the list I had a couple of traditional foods I wanted to try. The first was *vol-au-vent* (pictured), a chicken and mushroom stew. After checking out the Atomium, I visited a nearby sports bar/pub/restaurant, where I got a serving of this dish. Pleasant and easy flavor, goes down well with a pint.

Next on the list was *Carbonnade a là Flamande*, a dark ale-based (beef?) stew. Very comforting food on a rainy day. I had this at some touristy place at Grand Place.

{{ fig(src="grand_place.jpeg", alt="Buildings at the Grand Place on a nice half-cloudy, half-sunny day") }}

And of course, I tried Belgian chocolates and waffles. Pretty good!

I sadly didn't have the time to try *moules-frites*, which is, to my knowledge, a tasty heap of cooked clams.

Belgium is pretty known for its wide variety of beer styles. I wanted to learn more, and visited the Beer World Experience museum. The exhibition was rather lackluster, but at least the ticket included one beer of choice at the rooftop bar!

## Closing thoughts

The conference matched my expectations. I got to learn a lot about things that would have never crossed my radar otherwise.

The event was organized pretty well. There were a couple of issues, like the Wi-Fi only allowing HTTPS traffic (no SSH!), but it was all manageable.

Looking forward to next year!

[EuroBSDCon website](https://eurobsdcon.org)
