---
title: QCon London 2024 takeaways
date: 2024-04-20
extra:
  kind: post
---

QCon London 2024 was a multidisciplinary software engineering conference in the London QEII Centre in April 2024. I attended with the intention to learn about what's going on in the software-sphere. Especially in terms of software architecture.

This was also my first time in the UK so I had to do some touristing. The weather was a bit chilly, half-cloudy with some intermittent drizzle.

{{ fig(src="/files/london-from-above.jpg", alt="London from above in the late evening") }}

## Common themes

### Data products

A term from data mesh architecture. Think of the data you produce as a product. A product has an audience and marketing.

### Platform thinking, platform teams

Enable your software teams by building a platform of supported programming languages/runtimes, CI/CD pipeline configurations, deployment clusters, etc. so that each team does not have to spend resources reinventing the wheel.

Provide a _golden path_ (tried and tested technologies supported by the platform team) for new projects but do not smother your engineers' freedom of choice.

### “GenAI/LLMs are not necessarily that useful”

Probably comes as a surprise but the latest wave of AI hype isn't very substantiated. Issues of security, trust, quality, ownership and licensing. Keep a human in the loop.

### Safe, performant and ecological

Running software causes carbon emissions. Choose runtimes, programming languages and hosting options that minimize idle and active compute use.

Avoid entire categories of vulnerabilities by picking safe languages such as Rust.

## Most inspiring talks

### **The Home Computer That Roared: How the BBC Micro Shaped Our World** by _Jeremy Ruston_

A deep history dive to the advent of home computing in the UK. Jeremy was involved in building the educational BBC Micro computer as well as TV children's show animations and Doctor Who games. Super inspiring stuff, especially since I can relate to many of the constraints Jeremy et al. faced since I'm working on my very constrained "ATK16" hobby CPU project myself.

### **Thinking like an architect** by _Gregor Hohpe (AWS)_

Architects find connections. Between perspectives, between technologies, between people.

The director's budgets, risks and customer success are connected to the engineer's refactorings, scalability and backups.

Architects are an IQ multiplier, not the smartest person in the room. Architects make other people smarter.

### **Architecting for Data Products** by _Danilo Sato (Thoughtworks)_

Move from _left-to-right_ architectures (operational ↣ analytics) to a data mesh.

Make your data discoverable and usable via different protocols and formats. Make it self-serve (platform thinking).

> 🙋🏼 Note: I didn't know much about data mesh literature before this talk. The most useful things I got from it were the words and terms to look up, such as the _DATSIS principles_, and the books to read (see [Reading list](#reading-list)).

### **Building Your First Platform Team** in a Fast Growing Startup by _Jessica Andersson (Kognic)_

The spirit of DevOps has in part transmogrified into the idea of _software platforms_. DevOps as a term has degraded to just mean Ops in many places.
Empower product teams with an explicit platform. Each company has a platform, implicit or explicit.
A _base plaform_ should provide:

- **CI/CD**: pipeline templates, runner images, best practices
- **Runtime**: programming languages and runtimes, but also container runtimes, orchestration
- **Observability**: distributed tracing, logging, monitoring, alerting

## Reading list {#reading-list}

- ⭐️ [Team topologies](https://teamtopologies.com/book) by _Matthew Skelton and Manuel Pais_
- [Domain-Driven Design](https://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215) by _Eric Evans_
- [Data Mesh](https://www.oreilly.com/library/view/data-mesh/9781492092384/) by _Zhamak Dehghani_
- [Architect Elevator](https://architectelevator.com/) by _Gregor Hohpe_
  - all the other books by Hohpe also

## Word dump

I did not recognize these words or concepts.

- attestation testing, SLSA
- server-driven UI
- DATSIS principles
- data vault architecture
- source-aligned, consumer-aligned data products
- galaxy apps
- 2-step commit
- wardley map
- BPMN (business process model and notation)
- eBPF
- expand-contract pattern
- SCI (software carbon intensity)
- WASI (WebAssembly System Interface)
- Gartner hype cycle
- trust boundary (in context of LLMs)
- LLM agent
- shift left (in context of software platforms)

## Food and drink

### Fantastic Indian cuisine: [Dishoom Covent Garden](https://www.dishoom.com/covent-garden/)

You don't get Indian food like this in Finland. Super flavourful, suitably spicy. Was handed a gratis chai to drink while queuing up in the drizzling rain too. Excellent customer service.

### Real Ale Pub: [The Harp](https://www.harpcoventgarden.com/)

Nothing mindblowing, just good ale and a comfy vibe. A good place to sit out the rain.

### Bloody lovely: [Duke of Argyll](https://maps.app.goo.gl/21YHi1ZBrXohhczj9)

I had to eat fish & chips at least once just to check it off my bucket list. I don't know if theirs is the best or even proper, but I enjoyed it a lot.

{{ fig(src="/files/fish-and-chips-duke-of-argyll.jpg", alt="Fish and chips at the Duke of Argyll") }}
