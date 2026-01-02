---
title: "A home server journey, part 3: Installation"
date: 2025-12-23
description: |
  This is the third episode in a series where I set up a FreeBSD home server, explaining all the steps, problems and solutions along the way. This time we're installing the OS for the first time.
extra:
  kind: note
---

This is the third episode in a series where I set up a FreeBSD home server, explaining all the steps, problems and solutions along the way. This time we're installing the OS for the first time.

Check out episodes [1](/posts/home-server-part-1) and [2](/posts/home-server-part-2).

{{ toc() }}

## Installing FreeBSD

Installation should be pretty straightforward. I'm going to go with the latest stable release installer (`14.3-RELEASE`) in the `amd64` + `memstick.iso` variety. Let's burn the installer onto a memory stick, plug it in, and was enter the install wizard.

> Note from the future! `15.0-RELEASE` is already out, and I have recently updated to it. This post is already outdated!

The initial idea is this:

- ZFS, for all the automatic durability gains and easy-to-setup RAID1+0 (stripe of mirrors)
- encrypted ZFS datasets (kinda similar to partitions) for **jails**, which would contain all the actual services
- unencrypted root, so that I can reboot the machine remotely, physically unattended

> [Jails](https://docs.freebsd.org/en/books/handbook/jails/) are a lightweight way to containerize applications. They can get a separate process space, network stack, file system, root user, among others. They use the same kernel as the host, so they are more similar to LXC or OCI containers (think Docker, but more mature and flexible) than to virtual machines, which in FreeBSD are managed with [bhyve](https://docs.freebsd.org/en/books/handbook/virtualization/#virtualization-host-bhyve).
>
> Teaser: we will be installing `bhyve` later too.

Using the install wizard, I set up the system following my rough plan. And here we go, all up and running:

![Fastfetch output showing the machine specs. Disregard the uptime (I took the screenshot way later)](/files/pursotin_fastfetch.png)

### RAIDZ

You might notice that I bought 4 x 1 TB of NVMe disks, but `fastfetch` is only showing ~2TB. That's because I set up the disks into a "RAID 1+0" configuration:

![A "RAID 1+0" configuration](/files/pursotin_raidz.svg)

RAID 1+0 is a combination of two RAID levels. RAID 1, or _mirror_, consumes two disks to produce one virtual disk that has the capacity of only one physical disk but can withstand the loss of either one. ZFS can automatically heal missing data in a member of a mirror by copying it over from the healthy member. RAID 0, or _stripe_, consumes two disks to produce a disk that has the capacity of the sum of its member capacities as well as double I/O speed, but fails if either member disk fails. The combination of these is a useful way to get increased speed and increased durability at the price of half your raw capacity.

## Threat profile and encryption

To figure out what level and what kind of at-rest encryption I need, I need to stop and think about the threat model.

Scenario A, _online intruder_. An attacker that gains shell access can exfiltrate any data that the user has access to, since the decryption key has been activated at boot. At-rest encryption won't help here.

Scenario B, _burglar_. An intruder grabs the machine and brings it to a place where they can inspect the disks, possibly with sophisticated recovery tools.

- In a non-encrypted-root install, everything outside the encrypted jails is instantly accessible. Stored API keys and similar secrets leak. The administrator must take great care not to keep _anything_ of value on the unencrypted partition(s), and store everything in encrypted datasets.
- An encrypted root would be safe from this attack, assuming the cryptography used in the encryption is bulletproof.

Scenario C, _evil maid attack_. A friend, spouse or similar tampers with the unattended physical system. Illegitimate access is blocked by requiring login and keeping the credentials in my personal vault. If the whole disk is encrypted, the worst thing the attacker can do is cause temporary harm and possibly data loss by powering off the system. If not, the attacker can do all kinds of nasty things, like booting a live environment and copying the disk contents, replacing the kernel/bootloader, installing malware etc.

## Conclusion

It makes sense to encrypt the whole thing.

⚠️ But wait a minute! This is against my initial idea:

> unencrypted root, so that I can reboot the machine remotely, physically unattended

Encrypting the whole disk loses the ability to do unattended reboots. A bit inconvenient, but it is what it is. I'll just make sure to only reboot when I'm physically near the machine, which should be often, considering I work from home and the server is, uh, right there.

Because of this architectural change, I ended up installing FreeBSD for a second time, now with full disk encryption.

## System disk?

Sometimes a separate small system disk is used in addition to a redundant array of "data disks". I decided to not pursue this setup, since then the system would not benefit from the RAIDZ redundancy and self-healing capabilities. In fact, I'd imagine that the ability to repair the OS and packages is even more important to me than repairing bulk data.

I decided to keep the system next to the data on the disks (a "traditional" install).

## To be continued

In the next part(s) we will be looking at networking. I had some – let's say curious – issues with DHCP leases from the ISP. We'll also take a look at my jail setup.
