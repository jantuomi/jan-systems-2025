---
title: "A home server journey, part 4: Networking"
date: 2025-12-24
description: |
  This is the fourth episode in a series where I set up a FreeBSD home server, explaining all the steps, problems and solutions along the way. This time we're looking at networking.
extra:
  kind: note
---

This is the fourth episode in a series where I set up a FreeBSD home server, explaining all the steps, problems and solutions along the way. This time we're looking at networking.

Check out episodes [1](/posts/home-server-part-1), [2](/posts/home-server-part-2), [3](/posts/home-server-part-3).

{{ toc() }}

## Dual interfaces

I already have a private network (`192.168.0.0/16`) that uses my pfSense router as its gateway. The FreeBSD server will connect to this network through ethernet interface number one (`lan0`). Packets to and from local devices go through this interface.

The host will also be connected directly to the ISP's network using its second interface (`wan0`). This interface will get its IP using DHCP. Packets to the internet, as well as packets to public services running on the FreeBSD host go through this interface.

{{ fig(src="pursotin_network.svg", alt="A simplified diagram showing the two interfaces") }}

A dual interface set up like this is simple in theory, but there are important nuances, e.g. regarding return traffic routing and DNS.

## Routing

If we send a packet out through `eth0`, we should expect return traffic to arrive on `eth0` (and vice versa). However, it is rather easy to misconfigure the system.

Assume we have a public service, such as an `nginx` web server, which listens on the public interface. If we set up `rc.conf` naively like this:

```sh
defaultrouter=192.168.0.1
```

...the request might arrive through the public interface, but the response from the web server leaves through the private interface since we have configured the private gateway as the default. This is called _asymmetric routing_.

This might work! Both routes lead to the internet. From the perspective of the ISP, it doesn't really matter whether the packet went through the home router or not, in this case.

Sometimes however, this setup leads to the most vexing of networking issues. Figuring out what's wrong taught me a bunch about DHCP and layer 3 routing.

### Routing issue \#1: ISP DHCP server and MAC addresses

A DHCP server can keep track of clients using their MAC address. Separate physical interfaces have separate MAC addresses, so there is an obvious problem here. If an initial DHCP request broadcast leaves through one interface, and following DHCP requests (non-broadcast) leave through another interface, the DHCP server might see this as a forged packet.

This happened to me because of the `defaultrouter` setting:

1. The initial broadcast leaves through the `wan0` interface correctly. An IP is received.
2. When the lease is about to expire, a targeted request is sent to the now known DHCP server address. This is routed through `lan0` and `192.168.0.1`, since it's the `defaultrouter`.
3. The DHCP server sees the FreeBSD WAN MAC on first contact, and the home router MAC address on second contact. The lease is not renewed.
4. The lease expires, repeat from step 1.

My solution? Just don't use `defaultrouter`. As part of the routine DHCP song and dance, `dhclient` adds a valid default route to the system routing table. Just use that for all internet-bound traffic. You can see the routes with `netstat -rn`:

```sh
# netstat -rn
Routing tables

Internet:
Destination        Gateway            Flags         Netif Expire
default            87.92.64.1         UGS           wan0
87.92.64.0/18      link#36            U             wan0
192.168.0.0/16     link#25            U             lan0
127.0.0.1          link#57            UH            lo0
...
```

The `default` route was added by DHCP.

### Routing issue \#2: DNS-level ad blocker in my router

I run [pfBlockerNG](https://docs.netgate.com/pfsense/en/latest/packages/pfblocker.html) on my router to block ads on a DNS level (think Pi-hole). If I route traffic through the router, the return traffic is processed by this extra firewall. Some packets got dropped by pfBlockerNG and never arrived at the destination.

This was very annoying to debug! At least I had logging on, so I could confirm what's happening pretty quickly.

## DNS

Nameservers are defined on a whole system basis in `/etc/resolv.conf`, and not per interface or per IP. I have a basic DNS resolver running on my home server, so I simply configured my `resolv.conf` as:

```sh
nameserver 192.168.0.1
```

### Split horizon

Which IP should be returned from the DNS server if I query `some-public-service.jan.systems`? The private address from `192.168.0.0/16`, or a public IP reachable from the internet?

This is called **split horizon** DNS. One approach is to configure the DNS server to respond differently based on the address of the querying host. A private network host gets the private IP, etc.

I decided to not worry about this, and just use a separate domain, `local.jan.systems` for local addresses. This is a bit inconvenient, but I don't mind. The fewer DNS problems the better.

### DHCP and `resolv.conf`

By default, `dhclient` has a hook that overwrites `resolv.conf` with the DHCP-provided nameserver information. I want to always use my router as the DNS server, so I had to disable this functionality.

On FreeBSD, there are two simple solutions:

1. `resolvconf.conf`: a meta-config that configures the `resolvconf` tool, which is used internally by `dhclient`

To disable `resolvconf` altogether, add this to `/etc/resolvconf.conf`:

```sh
resolvconf=NO
```

Now, `resolvconf`, and transitively `dhclient`, won't overwrite your changes anymore.

2. making `/etc/resolv.conf` immutable with a flag

As root, you can set the file as immutable with `chflags`. Then, nothing can edit the file before the flag is removed.

```sh
chflags schg /etc/resolv.conf
```

Note that if you have a non-default [`securelevel`](https://man.freebsd.org/cgi/man.cgi?securelevel), you might not be able to remove this flag.

## Dual stack?

For now, I'm building everything on IPv4. My ISP has no support for SLAAC which makes IPv6 somewhat non-trivial. I will most likely add IPv6 at some point, but it's not a priority.

## To be continued

In the next part(s) we will be looking at provisioning with Ansible.
