---
title: 🌱 Now, spring 2024
date: 2024-04-22
description: Inches of snow are falling on the yard, covering any new green growths. The dog likes it, I don't.
extra:
  kind: now
---

Inches of snow are falling on the yard, covering any new green growths. The dog likes it, I don't.

<video width="100%" controls>  
  <source src="/files/jojo-in-snow.webm" type="video/webm">  
Your browser does not support the video tag.  
</video>

{{ toc() }}

## Travel

- Attended the [QCon London 2024](/posts/qcon-london-2024-takeaways) in London
- Went to [Tahko](https://www.tahko.com/en/) for a company leisure trip to downhill ski and snowmobile

## Music

[BLEK](/projects#blek) was live for 3 hours on student radio Radiodiodi with a dungeon synth genre deepdive program. According to metrics, 20 people (!) were listening to our show, which was also our grand EP premiere. Big leagues.

I bought a [cassette player](/posts/cassettes) and a bunch of metal and dungeon synth tapes, as well some empty ones from the Bezos shop. I'm planning to record BLEK's music on some of them.

## Games

We've been on a proper Ratchet and Clank binge, together with Marika.

- Ratchet and Clank: Rift Apart
- Ratchet and Clank: Tools of Destruction
- Ratchet and Clank: Gladiator (Deadlocked)
- Also we played the original trilogy in 2023

Non-Ratchet:

- Rollerdrome

Tabletop games:

- Started playing [Miru](https://hinokodo.itch.io/miru-an-analog-adventure-game)

## Reading

- _Category Theory for Programmers_ by Bartosz Milewski
  - Turned out to be quite a bit more difficult than I expected. The first half was completely doable with my functional programming and limited math background, but the second half is a piece of work. I'll push through though.

## Movies

I went to see Dune 2. It was as ok as the first part.

## Projects

### ATK16

Picked up [ATK16](/projects/atk16) again, adding some major stuff:

- A calling convention for functions: arguments in registers `RA`–`RG`, return value in register `RG`
- An emulator & step debugger in Python + Pygame for easier debugging
- A bump allocator for using the heap
- Ergonomics features in the assembler:
  - A `@data` directive for storing data in a data segment
  - A string datatype that is encoded as a length and data bytes in memory
- Some "standard library" stuff, like `memset` and `memcopy`
- A hardware monitor / shell-like program for interacting with the system in text mode
- An MMIO register for setting the interrupt flag in order to define critical sections for primitive interrupt concurrency

I feel like a proper introduction post / documentation is long overdue 😅 I should fix that.

### Garden (jan.systems)

Rewrote the site generator flow. Previously, each file in the content directory was accessed and processed from start to finish separately. This meant that there was no knowledge of other notes available when rendering a note. This made stuff like a [_dynamic now page_](https://derekkedziora.com/blog/dynamic-now-page) impossible.

Now, the flow starts by traversing the entire content directory and indexing it into an in-memory database. The database contains all the metadata and filesystem info of all the notes, as well as static files. This makes dynamic pages possible since the database can be queried at render time. This approach also improved performance, since I could reduce the number of filesystem reads and writes.

Things I still want to add:

- A bookmarking system, maybe somehow connected to the ~[liked](/liked) page~?
  - _Update from the future_: the liked page was migrated to the [linklog](/linklog).
- A project page structure (just a content thing, no code required)

## Previous update

[❄️ Now, winter 2023](/posts/now-2023-winter)
