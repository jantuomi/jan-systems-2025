---
title: Diddle, a minimalist event scheduler
weight: 0
extra:
  kind: project
---

I don't like Doodle. It pushes ads and its premium subscription relentlessly while simultaneously feeling like a clumsy, lumbering beast. There is also a lot to be desired in terms of accessibility and mobile-friendliness.

There are alternatives, like [dudle](https://dud-poll.inf.tu-dresden.de/) or [framadate](https://framadate.org/abc/en/). I could probably make do with those. However, to me this felt like an opportunity to spin up a quick MVP. This MVP turned into _diddle_.

Diddle ([live instance](https://diddle.jan.systems/), [Github](https://github.com/jantuomi/diddle)) is a minimalist tool that focuses on fast load times, accessibility and pragmatism. The feature set is based on my own personal requirements. It works great for quickly filling out a poll on mobile.

> **Note**: The instance hosted on my domain might go down any second. Use it at your own discretion.

{{ fig(src="../files/diddle_screenshot.png", alt="Diddle screenshot showing an answerable poll") }}

The first 80% of the project was done in two evenings. The last 80% was done during the next week. The tech stack is the _get-shit-done_ stack: **Python** + **Flask** + **PostgreSQL**. There is no required client side javascript: all client side logic is strictly for [progressive enhancement](https://developer.mozilla.org/en-US/docs/Glossary/Progressive_Enhancement). You can use "dumb" browsers like w3m or lynx to enjoy Diddle just fine.

Check out the README on Github for more info.

## Links

- [Github](https://github.com/jantuomi/diddle)
- [Live instance on diddle.jan.systems](https://diddle.jan.systems)
