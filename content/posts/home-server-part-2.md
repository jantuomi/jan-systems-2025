---
title: "A home server journey, part 2: Hardware"
date: 2025-10-04
description: |
  This is the second post in a blog series chronicling my progress with designing and setting up a new, physical FreeBSD home server.
extra:
  kind: note
---

<blockquote>“My first impulse, when presented with any spanking-new piece of computer hardware, is to imagine how it will look in ten years’ time, gathering dust under a card table in a thrift shop.”
<cite style="float: right">― William Gibson, Distrust That Particular Flavor</cite>
</blockquote>
<br>

This is the second post in a blog series chronicling my progress with designing and setting up a new, physical FreeBSD home server. Last time we went over my motivations, and this time we're looking at the physical hardware.

Check out episode [1](/posts/home-server-part-1).

{{ toc() }}

## Budget specs

My yearly cost in the public cloud is around 420€. It feels reasonable for a project of this caliber that a year’s expenses could buy a capable minicomputer.

What is a capable minicomputer then, you may ask. Well, my needs are pretty straightforward:

<table>
<tr><td colspan=2><strong>Qualitative requirements</strong></td></tr>
<tr><td>Usefulness</td><td>Can run a range of small to medium load web services without a hitch</td></tr>
<tr><td>Trustworthiness</td><td>Data is durable, disk failures are not catastrophic, I can sleep at night</td></tr>
<tr><td>Expandability</td><td>Can add more terabytes in the future</td></tr>
<tr><td colspan=2><strong>Quantitative requirements</strong></td></tr>
<tr><td>CPU</td><td>Low power, economical, can run FreeBSD.</td></tr>
<tr><td>Memory</td><td>Won’t OOM swap in day-to-day operation, ZFS is happy</td></tr>
<tr><td>Disk I/O</td><td>I don’t really care, no high-throughput required. As long as it’s not especially bad (i.e. HDD-level bad).</td></tr>
<tr><td>Disk space</td><td>Slots for multiple SSDs (RAID). Enough space to hold important files and some media with redundancy. No need for data hoarding.</td></tr>
<tr><td>Network</td><td>2 interfaces (private and public networks), Gigabit ethernet. No need for wireless.</td></tr>
<tr><td>Annoyance</td><td>Low noise, low temps, sleek form factor</td></tr>
</table>

With this list of requirements, I handwaved some models and numbers:

- CPU: Intel N series ⭐️
- Memory: 16GB
- Disk space: 2TB (usable)

> ⭐️ Intel N series processors, formally known as [Alder Lake-N](https://en.wikipedia.org/wiki/Alder_Lake#Alder_Lake-N) and [Twin Lake-N](https://en.wikipedia.org/wiki/Alder_Lake#Twin_lake-N), are affordable processors designed to be primarily used in mobile devices, lower end laptops (think Chromebooks) and small workstations. Some models, such as the N100, N150, N200 and N250, have thermal power ratings as low as 6W, making them popular in the passively-cooled, quasi-embedded design space: routers, NAS's, and the like.

I got the idea for an Intel N series chip from a friend who has succesfully set up computing cluster from a bunch of small machines with those chips. They seemed to be just what I was looking for.

With these, I sail off towards the east (AliExpress).

By the way, I also looked at ARM and RISC-V chips for this. I figured that if Apple Silicon can work as well as it does while being based on ARM, what's stopping me from reaping the same benefits, at least in part? ARM has T1 support from FreeBSD.

Turns out that there simply aren't any reasonably priced machines based on chips comparable to e.g. the Intel N150. Everything's either designed for mobile devices or just prohibitively expensive. Maybe there is no market yet for small non-x64 computers?

## Sourcing the silicon

AliExpress, an online retailer based in China, is nice since they have a huge variety of devices at prices that would never be profitable if sold in a western shop. I would prefer to buy European in this current political atmosphere, but I'm working off a budget, and limiting my options to reputable and ethical vendors would force me to relax my requirements a lot or stop the project in its tracks altogether.

![Some of the results of a "mini pc" search query](/files/aliexpress_minipc_results.png)

I'm happy to notice that there is a varied selection of devices at the ~200€ price point. Some are designed to be network devices, with a bunch of physical interfaces and limited storage options, while some are clearly NAS oriented, with SATA 3.5" drive bays capable of housing two or four disks, most commonly.

I'm looking for something in the middle ground: I need two physical interfaces (a property of router-likes) but I also need storage, preferably of the solid state variety (a property of NAS-likes).

**Conclusion**: I'm going with this one (possibly stale link warning): [Topton Pocket Mini PC](https://www.aliexpress.com/item/1005007905020917.html). With some mystery promotions applied, I had to only pay 162.27€, with free shipping. I also purchased 16GB of RAM (Crucial DDR5 SODIMM 4800MHz) separately, also from AliExpress.

> AliExpress tends to have multiple layers of ‼️ LIMITED SALE ‼️ and 🤑 TOP DEAL COUPON 🤑 going on at the same time. In the mobile app they also have a bunch of connect-four-type games that can score you big AliExpress Coins©. Please continue consuming.

![A promotional image of the mini PC I picked, hosted here in case the product page goes poof. Please enjoy the broken English.](/files/aliexpress_minipc.png)

Regarding disks, I think I want to buy them locally, just in case there are issues with them. It's way less stressful to handle returns and such with a local vendor than with an overseas megacorp. I feel that stuff like RAM is pretty often OK even if bought from less reputable sources, but with disks I don't want to test my luck.

**Conclusion**: I'm going to get 4 x 1 TB (double the required usable space because of mirroring) of basic NVMe drives from a computer parts shop (Gigantti) nearby.

## Setting up hardware

The box arrives after a bit of a wait (par for the course for the cheapest delivery option, China Airmail). Everything seems to be in order content-wise, but there is no installation manual whatsoever included. I would like one, since I need to figure out how to install the RAM stick. It seems to somehow go below the NVMe sticks, but there is no obvious mechanism for detaching the NVMe bay.

However, with a bit of trial and error I find the correct screw to remove. The top layer comes off, revealing the RAM stick slot underneath. Very carefully I slot in the memory and push down the clamp that fixes it in place.

With similar care I put the drive bay back in, and connect the four NVMe drives and stick on their respective thermal material stickers that conduct heat for the drives to the heatsink on top of the machine. I screw everything in place with the tiny screws that came with the machine. A magnetic screwdriver would be a godsend now!

After a bit, everything's put together. After connecting the power cable, the machine powers on without me even touching the power switch, which is a bit surprising, but ok. I hear the POST beep.

Success!

## To be continued

In the next part(s) we will be looking at installing FreeBSD for the first (and second) time, and networking. I had some – let's say curious – issues with DHCP leases from the ISP. We might also take a look at my jail setup.
