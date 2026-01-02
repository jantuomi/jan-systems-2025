---
title: ☀️ Now, summer 2025
date: 2025-06-15
description: |
  Here's three seasons of updates in one package.
extra:
  kind: now
---

{{ fig(src="/files/kenrokuen.jpg", alt="A torii gate in the Kenroku-en garden") }}

Here's three seasons of updates in one package.

{{ toc() }}

## AutereDB project

I was reading [Designing Data-intensive Applications](https://www.oreilly.com/library/view/designing-data-intensive-applications/9781491903063/) and I came across a chapter where the author goes over log-structured database architecture. I knew about B-tree based systems, but this seemingly simpler approach was new to me. I was intrigued, but I also felt like I didn't fully grok how every cog in the theoretical database machine worked together.

Therefore, I decided to write a quick MVP thing in Rust during a conference flight. The result is **AutereDB** ([Github](https://github.com/jantuomi/autere_db)).

AutereDB is more like a database engine. It doesn't have a query language, authorization mechanisms, multi-table support or other higher-level features. It simply makes sure that records are written to disk as expected, and queries return the correct data.

You can read more about the project in the `README.md`.

I have no plans to really further this project. I feel it was a one-off to better grok how these things work. I consider this goal met; I am now more confident about reasoning about data systems. Many things that I learned the hard way during this project have already proved to be beneficial in my day job, so mission success.

Help yourself to the `ARCHITECTURE.md` file in the repository, and have a laugh at how I made multiple major miscalculations early on in the project, and then scrambled to fix these as I realized my folly. I tried to document most of these in the architecture decision log, for posterity.

## FemtoQueue project

Another data-centric project I conjured up: a Python task queue library that uses files in the filesystem for task persistence, and `rename()` to atomically move tasks from one state to another.

FemtoQueue is on [Github](https://github.com/jantuomi/femtoqueue), as well as on [PyPI](https://pypi.org/project/femtoqueue/) as a pip-installable package.

I'm pretty proud of this one. The core idea fits in under 100 lines of no-dependency Python. The current version with QoL stuff and docstrings clocks in at around 350 LoC. I could see it being very useful for small projects where you need some kind of a durable queue for sending emails etc., but don't want to add a whole separate networked Redis-like thing, or Celery or a home-cooked SQLite-based solution.

## Japan trip

Me and my fiancée made a long-awaited trip to Japan in the spring. We landed in the KIX airport near Ōsaka right in the middle of the cherry blossom season, hanami.

We traveled the central island, Honshū, for three weeks. Mostly by train, but also by bus. We visited Ōsaka, Nara, Kyōto, Gifu-Takayama, Kanazawa and finally Tōkyō. This route skips the popular south-coast bullet train connection, instead going north through the mountains.

{{ fig(src="/files/samurai_garden.jpeg", alt="The garden of a preserved samurai family home, with a koi fish pond and stone lantern") }}

I got to finally test my Japanese. Speaking was very laborious at first, but it got way easier the more I got to practise. My vocabulary didn't improve that much, but what improved were things like _cadence_, _[aizuchi](https://en.wikipedia.org/wiki/Aizuchi)_, and ability to respond with more natural word choices. Big up to active listening and copying native speakers.

We ate and drank well. We mostly gravitated towards traditional-style, or _washoku_, establishments. Our favorite meals were prepared by a sweet grandma in a hot springs guesthouse in the mountains. Simple and clean ingredients.

Something to note: pickled veggies go great with meat-centered, hearty meals. We were eager to implement this in our home cooking as soon as we got home.

{{ fig(src="/files/wagyu_grill.jpeg", alt="Wagyu beef, mushroom and peppers on a tabletop charcoal grill") }}

We visited the obligatory tourist spots, like the _Thousand torī gates_ in Kyōto, and the _Dōtonbori shopping street_ in Ōsaka. We like seeing sights, but we know that our most memorable experiences have always come naturally from exploration and keeping an open mind. That's why we spent only a fraction of our time visiting Tripadvisor locations and most of the time wandering around, following local recommendations and keeping our eyes, ears and nostrils peeled.

We are planning to travel there again, maybe on honeymoon.

## FreeBSD home server

I have recently started a project of setting up a small publicly accessible home server that will replace my DigitalOcean VPS in some time. The system will be very FreeBSD jail focused. I have just received the hardware and verified that the everything is up to par. Very hyped about this one.

I am planning to write some posts about the progress.

## Home

A lot of small things need renovated. I guess this is what owning a house is. We have done a lot, and even more is still on the backlog.

しょうがないね。

Going to install some patio roofing during the next couple of weeks, first time doing that.

## Books

Mostly FreeBSD stuff by [Michael W. Lucas](https://mwl.io/nonfiction/os).

**Finished**

- [Designing Data-intensive Applications](https://www.oreilly.com/library/view/designing-data-intensive-applications/9781491903063/) (took a long time to work through this one)
- FreeBSD Mastery: Storage Essentials

**Started**

- Absolute FreeBSD
- FreeBSD Mastery: ZFS
- FreeBSD Mastery: Jails

## Games

**Played**

- Gato Roboto
- A Short Hike
- Cozy Grove (watched my fiancée play this one)
- Warhammer 40k: Boltgun

**Enjoyed as a VOD/live stream**

- Blue Prince
- Rainworld

## Anime

- Jujutsu Kaisen 0, S1, S2
- FLCL Progressive
- Demon Slayer: Mugen Train
- Evangelion rebuild movies
- Blame! (movie)
- Puella Magi Madoka Magica
- Dandadan
- Chainsaw Man (still a couple of eps to go)

## Previous update

- [🍁 Now, fall 2024](/posts/now-2024-fall)
