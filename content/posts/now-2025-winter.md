---
title: ❄️ Now, winter 2025
date: 2025-12-16
description: |
  Fall has gone by, fast. Mostly rain and darkness. Managing the estate of my late father has taken up a lot of time I would've otherwise spent on hobbies.
extra:
  kind: now
---

Fall has gone by, fast. Mostly rain and darkness.

Managing the estate of my late father has taken up a lot of time I would've otherwise spent on hobbies.

Some decor and reno at home, some game programming, a lot of games. Game design has been on my mind a lot lately.

I also attended my first ever Finnish defence forces reservist refresher training exercise. I had a good time!

{{ toc() }}

## Metroidvania game dev

🚨 Original game idea alert 🚨

I decided to make a 2D platformer with ability-gated progression. It's gonna have pixel art too.

It's been a very long time since I made a complete game project. I don't care about how many players I'm gonna get. I just want to create a game, for me.

I figured I should do some proper design upfront instead of doing the easy thing, i.e. jumping straight into programming mechanics. That's why I started writing a Game Design Document ASAP. With that, maybe I can come back to this project easier, after the inevitable plateau and loss of interest.

Maybe some screenshots later.

## Future of ATK16

An idea came to me in my sleep. I want to change the course of my computing project ATK16 and turn it into a stack-based, Forth-like system.

Clearly I've been subconsciously processing ideas from Forth and [Uxntal](https://wiki.xxiivv.com/site/uxntal.html), since my current vision is a hodgepodge of features from those two:

- an interactive REPL-compiler, able to compile native code on the fly
- a system-wide dictionary (map of symbols to code or data), giving structure to the linear memory
- reverse Polish notation, which falls naturally out of the stack machine design

A basic session could look like this:

```sh
ATK16 v0.1
Dictionary usage: 10 KB

: average3 (a b c -- avg)
    + + 3 / ;
```

This would define a new symbol, `average3`, that computes the average of the top 3 elements on the stack and pushes the result on the stack. The stack could be implemented in hardware with a top-of-stack optimization: the top three slots live in fast registers, while the rest is in dedicated SRAM. This would allow fast access to the most important, i.e. topmost, elements of the stack.

In addition, I'm thinking of doing some things a bit unorthodox:

- The system dictionary could live in FRAM, which is non-volatile. All symbol definitions would then be automatically persistent, like files on a disk. This could be huge.
- A programmer board could then allow me to directly update this dictionary from my dev laptop, possibly by emulating the same REPL software that runs on the hardware.

In fact, it might be possible to design this in a way that completely does away with assemblers and cross-compilers. I would just need an emulator and a bit of bootstrap assembly that implements a minimal REPL that can self-compile new symbols into the dictionary. Like this, I wouldn't need to worry about ensuring that the assembler and self-compiler work exactly the same: there is only one compiler implementation! I just emulate it on my laptop. Everything is implementation defined!

## Home

### ”Dopamine office” decor

Office room number one is now pretty much complete. We tried to combine some of pastel colors and fun patterns, while keeping it smart and tidy.

{{ fig(src="/files/dopamine_office.jpeg", alt="The dopamine office") }}

### Backdoor clothes rack and wall feature

We use our apartment's back door a lot, more than the front door really. It's easier to take the dog out that way.

Until now, there has been nowhere to really hang our outdoor clothes nicely. The dining table and its chairs have doubled as a clothing rack (not ideal).

So we got the idea to repurpose the empty space in the corner, adding some visual interest with acoustic paneling as well as utility with some colorful "knobs" that you can hang coats and scarves on.

{{ fig(src="/files/backdoor_feature_wip.jpeg", alt="Install in progress") }}

And the final product (in completely different lighting):

{{ fig(src="/files/backdoor_feature_done.jpeg", alt="An installed wood paneling with some coats hanging off of colored knobs") }}

The white box is an IKEA shoebox. We keep some dog gear in there.

### Cool dog print

{{ fig(src="/files/taulu_koira.jpeg", alt="Cool dog") }}

## Games

**Played**

- God of War: Ragnarök
- Cocoon
- Another Crab’s Treasure
- Super Metroid
- Metroid Dread
- Prince of Persia: The Lost Crown
- Ori and the Blind Forest

## Anime

**Finished**

- Bocchi the Rock S1
- Spirited Away (movie)
- Ghost in the Shell (movie)
- Kill la Kill

**Started**

- Dandadan S2
- Spy x Family S1

## Tunes

Mostly [Moomin music](https://youtu.be/Bf1pR4rkPK8). I went to see the _Muumimusiikkia_ show in Musiikkitalo (Helsinki) in November, and after that I haven't been able to get Shiratori's melodies out of my head. This is a positive problem.

{{ fig(src="/files/muumimusiikkia.jpeg", alt="A photo from our seats at Musiikkitalo, showing the brochure") }}

### Spotify Wrapped

I feel like I'm using Spotify less and less. Might drop the subscription in the near future. I really don't like the policies they are driving.

{{ fig(src="/files/2025_wrapped_genres.jpeg", alt="My top genres, all over the place") }}

## Previous update

- [🍁 Now, fall 2025](/posts/now-2025-fall)
