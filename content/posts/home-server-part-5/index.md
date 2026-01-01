---
title: "A home server journey, part 5: Ansible"
date: 2025-12-26
description: |
  This is the fifth episode in a series where I set up a FreeBSD home server, explaining all the steps, problems and solutions along the way. This time we're provisioning the server with Ansible.
extra:
  kind: note
---

This is the fifth episode in a series where I set up a FreeBSD home server, explaining all the steps, problems and solutions along the way. This time we're provisioning the server with Ansible.

Check out episodes [1](../archive/home-server-part-1), [2](../archive/home-server-part-2), [3](../archive/home-server-part-3), [4](../archive/home-server-part-4).

{{ toc() }}

## Automation

[Ansible](https://docs.ansible.com/projects/ansible/latest/index.html) is a tool for running a bunch of Python scripts, or "tasks", in a kind of declarative way. It's commonly used for provisioning servers.

My ansible configuration is publicly available on my GitHub. I update it regularly.  
🌐 [jantuomi/ansible-freebsd-home-server](https://github.com/jantuomi/ansible-freebsd-home-server)

I have only one server, and I'm planning to have it for a long time. Why would I need automated provisioning? It seems like an extra step when I could just provision everything manually. There is no need to synchronise multiple hosts or anything like that.

I view this kind of automation as executable documentation, or readable instructions for both the computer and the human. If I define the server in terms of these Ansible tasks, I can (in theory) reconstruct what's been done with the server just by reading the Ansible playbook.

To be reliable, this necessitates that everything is defined in Ansible. Which happens to be very difficult to actually do.

## Project structure

There are many ways to structure an Ansible project. I picked one that I consider to be simple:

- a single main playbook, with tags for selective execution of sub-playbooks
- a non-tracked `secrets.yml` that contains all secret values
  - reasoning: this way I don't need to parse a separate configuration format and I get access to all features of YAML, including its data structures (lists, objects), which I would be lacking if I used a flat file format such as `.env`.
- a flat file hierarchy with names mirroring the target path, e.g. `templates/root_ssh_config.j2` goes to `/root/ssh/config`.
- no handlers and notify, because I want complete control over the execution order

This is my first non-trivial Ansible project, so I wouldn't be surprised if I have some anti-patterns in there.

The playbooks are designed to be fully _idempotent_: I can run the playbook again after the first run and expect the system to be in the same state. This is very important, since I want to be able to fearlessly run any playbook at any time and expect a success, or at least a helpful failure that doesn't compromise basic operation of the host.

The only host in the Ansible inventory is my server. I run the playbook like this from my development laptop:

```sh
$ ansible-playbook -i inventory playbook.yml
```

If I want to only update the `ingress` jail, I run:

```sh
$ ansible-playbook -i inventory playbook.yml -t jail_ingress
```

## Separation of responsibilities

Let's borrow and tweak the standard cloud infrastructure stack diagram that shows what parts of the stack are handled by the cloud provider and what parts are handled by the customer.

My current approach is to use Ansible for the "core" parts of server administration, installing packages, defining service jails, etc:

{{ fig(src="pursotin_stack.svg", alt="A stack model depicting the software layers in my server") }}

Some notes about this setup:

- The top "application layer" is currently a chaotic no-man's-land with varying levels of automation. Optimally I could rebuild all service jails completely with Ansible.
- The host OS release is managed manually, i.e. release upgrades are run manually with `freebsd-update`. This is fine IMHO. I will be supervising all the few and in between OS upgrades anyway, so automation does not help much there.

## Why not Chef, Salt, etc?

Ansible is very simple. It's pretty much a framework to write idempotent shell scripts without having to write shell scripts. Or Python scripts, whichever way you want to look at it.

It's agentless. I don't have to run a service on the FreeBSD host to use Ansible. It uses SSH as transport and runs the tasks with Python, both of which are software that I expect to be present on any \*nix server.

{{ fig(src="ansible_task_postgres.png", alt='A snippet of Ansible playbook installing PostgreSQL in the "postgres" jail') }}

## How about containers?

I'd image that most new server setups in 2025 are designed with container workloads in mind. This one is too, kinda.

I isolate most services with FreeBSD jails, which are similar to OCI containers. Processes are isolated from other jails and the host automatically. Virtual networking (`vnet`) isolates the network. ZFS snapshots and clones provide thin jail filesystems that have a small storage footprint. Jails share the host kernel.

Many OCI container concepts translate well to jails, but jails are somewhat more _persistent_. Conventionally, jail filesystems are not ephemeral and survive jail restarts.

Only `ssh`, `bash`, `vim` and some other packages are installed on the host directly. Everything else is 🔐 _incarcerated_ 🔐.

{{ fig(src="pursotin_jls.png", alt='A list of running jails on the server') }}

### FreeBSD OCI container support

FreeBSD was [recently welcomed](https://forums.freebsd.org/threads/an-introduction-to-oci-containers-on-freebsd.99907/) into the prestigious club of platforms that can run OCI containers. This was achieved by using jails as the container runtime and `podman` as container manager.

This pretty much means that we can use Dockerfiles/Containerfiles to define our jails. Existing Containerfiles cannot be used directly, since they are built on Linux base images, but they can be used as a starting point for building new, FreeBSD-based images.

While this sounds very cool and promising, I want to let the implementation mature a bit before building everything on it.

> I tried installing the `podman-suite` package and following the instructions, and promptly broke all of my networking, so yeah 😑

I'm sure OCI containers will be a valid and respectable approach to containerization on FreeBSD, after the kinks have been ironed out.

## To be continued

In the next part(s) we will be looking at the specifics of the jail setup, e.g. how to create jails using `jail.conf.d` scripts.
