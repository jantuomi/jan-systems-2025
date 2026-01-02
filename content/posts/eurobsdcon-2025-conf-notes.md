---
title: "EuroBSDCon 2025: conference notes"
date: 2025-10-17
extra:
  kind: note
---

EuroBSDCon is one of the events organized under the BSD community umbrella, focusing on all things related to and descending from 4.4 Berkeley Software Distribution. This year's event was held between September 25th and 28th in Zagreb, Croatia, but the city and country change every year.

My event experience consisted of two days of "trainings", sometimes also referred to as labs, and two days of conference proper. In addition to these, there were also dev summits and smaller "conference-in-a-conference" kind of deals related to some BSD subsystems like `bhyve`, but those were not relevant to me so I skipped them outright.

The event was held at the Faculty of Electrical Engineering and Computing (University of Zagreb). The venue was nostalgic in a way since it reminded me a lot of the building where I started my studies in Aalto University. Functional.

{{ fig(src="/files/eurobsdcon_2025_hallway.jpeg", alt="A photo of a stairway in the conference venue") }}

Recordings from the presentation rooms can be found on [Youtube](https://www.youtube.com/playlist?list=PLskKNopggjc6bnhXOX5MQbaPKEvohzjYH). You might have to check the talk schedule to find the timestamp of a given talk.

## Kernel deep-dive

I attended a two day lab by Prof. Kirk McKusick, who is a well known figure in the BSD world, having worked on core operating system components in the formative years of the BSD lineage. I really enjoyed his relaxed but still intensive teaching style. The lab, or maybe _interactive lecture_ would be more fitting, was an introduction to the FreeBSD kernel subsystems, explaining how things like I/O, scheduling, filesystems and networking work in the kernel.

> Note that the FreeBSD kernel is not the same as the Linux kernel, or the other \*BSD kernels either for that matter. It is FreeBSD exclusive, but it shares history with other systems that descend from 4.4BSD, which is the common ancestor for many Unix-like OSs.

You see, I'm not a huge kernel guy (at least not yet) so I was a bit worried that the lab content would go over my head. What happened though surprised me: I understood something like 90% of the material. Apparently I had the necessary prerequisite knowledge after all, or maybe Kirk was just so good at teaching. Maybe both.

{{ fig(src="/files/eurobsdcon_2025_binders.jpeg", alt="Two spiral notebooks of lecture notes, one for each day") }}

## Favorite talks

There was a healthy range of themes in the talk schedule. Some were straightforward demos of recent development efforts, some were about history (mostly 1970–80s, the childhood years of the BSD project). Some war stories as well, explaining how the speaker et al. dealt with some hindrance. There were also some, I would say _not so BSD-related_, talks about things like data and identity ownership, federated social media, freedom. There is a bunch of overlap between BSD enthusiasts and digital freedom enthusiasts so it was only fitting.

Here's my top 3, based on overall vibes.

### _Lessons learned Open Sourcing the UK's Covid Tracing App_, by Terence Eden

Terence was the third in line in the Saturday's opening keynote schedule. Terence was one of the key engineers behind the open source Covid tracing app that the UK developed and used. The keynote handled themes of public relations, talking about software licenses to lawyers, protecting privacy of developers from the wrath of the public, successful platform launches and shutdowns... a lot of stuff delivered with great pacing and enthusiasm.

Timestamped link to this talk: [Youtube](https://www.youtube.com/live/qdEMmM5g27M?t=1221)

### _Enhancing Unix Education through Chaos Engineering and Gamification using FreeBSD_, by Benedict Reuschling, Andreas Kirschner

Benedict and Andreas had noticed that their students at Hochschule Darmstadt were not very proficient when it came to administering a UNIX system and debugging issues on it. They devised a platform where their students use exercise environments (with root access) and solve problems like DNS problems against the clock. The fastest student teams get winning points on a leaderboard.

The talk format was a mix of a war story and tech demo: they explained their pedagogical conundrum and walked the viewers through their solution, which was based on FreeBSD and liberal use of jails.

Timestamped link to this talk: [Youtube](https://www.youtube.com/live/FgtTVzYFEF0?t=23860)

### _AI slop attacks on the curl project_, by Daniel Stenberg

Daniel is the main developer in the `curl` project. In his Sunday keynote he explained how the project is being pestered by AI generated, low effort security issue reports that take up a lot of contributor time to review. Why not just block those people outright? Daniel argues that they take all reports indicating a critical vulnerability seriously; they can not allow to mistakenly disregard a valid report.

Daniel is an entertaining speaker with big responsibility in the open source world.

Sadly, the talk seems to not be recorded on Youtube.

## Community

I was curious to see what the people are like. I knew that BSD is a pretty niche thing so I was afraid the community might be hard to get into, but I was happy to notice that everyone that I talked to seemed very welcoming and excited to share.

I noticed that there was very little "hierarchy" at the event. Speakers, sponsors and attendees were all mingling together at lunches and at social events. I didn't really see signs of cliques or circles that didn't accommodate newcomers.

Since the event, I have familiarised myself with BSD community channels such as the [FreeBSD IRC channels](https://wiki.freebsd.org/IRC/Channels) on Libera.Chat and the various forums of [BSD Cafe](https://wiki.bsd.cafe/), hosted by Stefano Marinelli, who was also speaking at the conference.

{{ fig(src="/files/eurobsdcon_2025_group.jpeg", alt="A group photo was taken on the final day") }}

## There and back again, and the touristy bits

There were no direct flights from Helsinki to Zagreb, so I had to layover in Germany both on the way there and on the way back. Leaving Finland, the departure time was gnarly: around five in the morning. Good thing I can sleep in economy. I had plenty of time to change planes, and got to the destination without a hitch.

I stayed in B&B Boutique Casablanca, which was a nice bed & breakfast place with friendly staff.

Traditional & local foods were my primary target when looking for restaurants. My top picks:

- **ćevapi** at _Plac_ ([Tripadvisor](https://www.tripadvisor.com/Restaurant_Review-g294454-d7075337-Reviews-Plac-Zagreb_Central_Croatia.html)), pictured below
- **štrukli** at _La Štruk_ ([Website](https://www.lastruk.com/))

{{ fig(src="/files/eurobsdcon_2025_cevapi.jpeg", alt="A serving of ćevapi with cream cheese and paprika spread") }}

The return trip was more eventful. The plane didn't start boarding until it was more than an hour late. We were never told the reason. That delay caused me to miss my connecting flight 😑

I was rerouted via Frankfurt which turned my nice "get home for dinner" schedule into a gruesome "you're home sometime between midnight and 2 AM" trek. Luckily I got a seat on both of the rerouted flights (that was not a given). I was home after 1 AM.

I have then learned that there would have been a very nice direct route from Finland to Ljubljana, which lies just across the Croatian border, accompanied by a bus route that would have taken me from city to city in a couple of hours. Now I know.

## The next event

...will be held in Brussels, Belgium. It's closer to Finland (👍) but I've heard that it's kind of a dull city to visit. Whether that's true or not, I don't know really, never been there before. But I'd prefer going a bit farther away from my home to escape the weather 😅

[EuroBSDCon 2026 website](https://2026.eurobsdcon.org/)
