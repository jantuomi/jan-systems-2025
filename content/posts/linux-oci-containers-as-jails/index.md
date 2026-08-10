---
title: Linux OCI containers as plain FreeBSD jails (without Podman)
date: 2026-08-10
extra:
  kind: post
---

> **Abstract**: Linux software distributed as OCI container images can be extracted into a FreeBSD jail with Linux compatibility enabled. With a couple of mounts set up to make the extracted root a valid Linux userland, the "container" can run like a regular jail without involving virtual machines or a separate control interface (`podman`). Isolation is handled by the jail subsystem.

{{ toc() }}

FreeBSD has a respectable library of ported software in the [ports tree](https://www.freshports.org). Getting ported software set up is usually just a `pkg install` away. Sometimes you have to take a couple of extra steps and run a `make install`. Some programs do not have a port but can be made to run anyway, by tweaking a Makefile, setting up an ad-hoc Python environment, or something to that effect.

Some programs, however, are designed to be run in a very particular, Dockerfile-specified, Linux-library-dependent environment. 

My first encounter with this kind of challenge was [Immich](https://immich.app): a self-hostable personal photo and video gallery.

Immich has an elaborate Dockerfile setup. I tried my darndest to reverse engineer the steps to install it into a fresh FreeBSD jail, free from any extra layers of administrative abstraction.

It's a NodeJS app, can't be that hard. I've done this a bunch of times.

Turns out, in contemporary NodeJS fashion, the build involved:

- various Rust build steps for some kind of SDKs and plugin systems
- binary blob direct downloads (Linux-only of course)
- a flurry of bind mounts from earlier build stages

etc, etc.

The absolute state of web software complexity in `$current_year`.

I gave up and started looking for an alternate approach.

## The classic solution (Linux VM)

I booted up a [bhyve](https://bhyve.org) virtual machine running [Alpine Linux](https://www.alpinelinux.org). I used the venerable [vm-bhyve](https://github.com/freebsd/vm-bhyve) wrapper.

With the vm running, I just installed podman with `apk add podman` and started the immich services with `podman compose up`.

> Ok, not all services. I still ran PostgreSQL and Valkey in a FreeBSD jail, outside the vm. It would be wasteful to virtualize those, since they run without a hitch on FreeBSD. I just made sure to give the vm a local IP that's in the same subnet as my jails.

The problem was immediately solved. It is trivial to run Linux containers when you have a Linux box.

However, I was not content. The virtual machine was consuming more resources than all of my jails and natively running services combined. A fresh Alpine install has more background processes running than my production FreeBSD server.

I have to run a full Linux kernel and a bunch of processes just to run this one Node.js app.

Also, the vm sticks out like a sore thumb in my otherwise clean jail setup. It needs a bunch of purpose built machinery to provision and manage. I cannot keep it up to date with `zfs clone`, `freebsd-update` and `pkg upgrade`. Monitoring needs to be set up separately. Logging needs to be set up separately.

## The cutting edge solution (Podman + Linux containers)

The container runtime _podman_ [supports FreeBSD since `14.3-RELEASE`](https://podman.io/docs/installation#installing-on-freebsd). In addition to being able to run OCI images built on a FreeBSD base image, podman is able to run Linux containers as well using the FreeBSD Linux compatibility layer.

This is fantastic and probably the future of containers of FreeBSD. However, I do not want to set up podman on my server, at least not yet. 

Podman has an opinionated approach to networking and storage. Networking requires specific `pf` firewall rules and storage is modelled in a way that is not compatible with how I manage my jail ZFS datasets. And maybe most importantly, container services would require using the `podman` interface instead of the traditional `service`/`rc` interface, which I use to manage everything else on the box.

Using podman for a single service would complicate things. Unnecessarily, in my opinion.

I didn't set up podman to run Immich. Instead, I started designing a custom approach, that would still let me use the tools I use everywhere else and avoid needless performance overhead.

## My custom solution (Linux jail + extracted container file system)

The core idea of my solution is to note a central fact: a container image is basically an archived Linux userland. What if I follow the FreeBSD Handbook's instructions on [how to run a Linux jail](https://docs.freebsd.org/en/books/handbook/jails/#creating-linux-jail) and adjust the steps to run in the container root filesystem instead?

Through some trial and error, I got a setup working. I'll walk you through the main steps in a tutorial fashion, using the `immich-server` container as an example.

### Preparing the host and starting an interim jail

First things first: Enable Linux compatibility on the host.

```sh
[host]$ sysrc linux_enable="YES"
[host]$ service linux start
```

Next, set up a jail filesystem. I used `zfs clone` to clone my `15.1-RELEASE` template (which is based on the same release as my host) into a new jail root. Call it `immich-server` because it matches the name of the container I'm planning to run in it. My jail filesystems live under `zroot/jails/containers/`:

```sh
[host]$ zfs clone zroot/jails/templates/15.1-RELEASE@base zroot/jails/containers/immich-server
```

Use a direct `jail` command to set up basic networking and select the filesystem path. This isn't the final configuration: you just need it running to set up the immich container.

```sh
# see that the IP and interface match your setup
[host]$ jail -cm \
    name="immich-server" \
    host.hostname="immich-server" \
    path="/usr/local/jails/containers/immich-server" \
    exec.clean \
    allow.raw_sockets \
    interface="lan0" \
    ip4.addr="192.168.4.1" \
    exec.start="/bin/sh /etc/rc" \
    exec.stop="/bin/sh /etc/rc.shutdown"

[host]$ jexec immich-server /bin/sh
[immich-server]$ 
```

You now have a shell in the jail.

### Extract the OCI image

Next, you need to 1) download the image, and 2) extract the image filesystem into a jail. Luckily, the OCI ecosystem has suitable programs for these tasks: the [umoci](https://github.com/opencontainers/umoci) and [skopeo](https://github.com/podman-container-tools/skopeo) command line tools.

These tools are only needed during _build time_, i.e. while constructing the container jail. They are not needed during runtime. You might choose to install them in the jail, and perhaps uninstall them later. Or maybe install them on the host and operate on the jail filesystem from the host side, keeping the jail _clean_. Maybe one could even set up a temporary "build jail"? I went with the first option, and just installed the tools in the target jail, `immich-server`.

With `skopeo`, you can download a Linux OCI image into a file in the filesystem:

```sh
[immich-server]$ pkg install skopeo
[immich-server]$ TAG="immich-server:v3.0.3"
[immich-server]$ skopeo copy --override-os linux docker://ghcr.io/immich-app/$TAG oci:$TAG
```

This creates a directory called `immich-server` in the current directory. The directory contains the manifest and the layers.

Then, use `umoci` to extract the layers into a valid Linux userland. Just one problem: `umoci` does not have a FreeBSD port or a FreeBSD binary build. Fear not! The Linux binary is statically linked and the jail has Linux compatibility, since you enabled it on the host.

```sh
# Assuming amd64 arch here
[immich-server]$ fetch https://github.com/opencontainers/umoci/releases/latest/download/umoci.linux.amd64
[immich-server]$ install -m 755 umoci.linux.amd64 /usr/local/bin/umoci
[immich-server]$ mkdir /linux
[immich-server]$ umoci unpack --image $TAG unpacked
```

The `unpacked` directory contains the `rootfs` as well as some metadata. `unpacked/config.json` is worth checking out: it contains values that are defined in the Dockerfile, such as: `env`, `command`, user `uid` and `gid`, working directory path. Those can be used later, when we set up the service to start up the app.

Let's move `unpacked/rootfs` to an easy absolute path: `/linux`.

```sh
[immich-server]$ mv unpacked/rootfs /linux
```

Chroot inside and see that it acts like a Linux system should:

```sh
[immich-server]$ chroot /linux /bin/sh
$ uname -s
Linux
```

### Mounting special device nodes and defining the final jail

Some containerized apps might work already, but most need specific device nodes to function. Let's exit the chroot and shell, and stop the jail.

```sh
[host]$ jail -r immich-server
immich-server: removed
```

Now, define the jail properly with a `jail.conf`, taking inspiration from the Handbook. You can also use `bastille`, `iocage` or any other jail manager/wrapper to do this. The goal here is to set up a normal Linux userland with the expected dev nodes as well as special filesystems like `/proc` and `/sys`.

Mount also any directories that are used during runtime, i.e. those that are handled by volume or bind mounts when using OCI containers.

Edit as needed:

```
immich-server {
  # STARTUP/LOGGING
  exec.start = "/bin/sh /etc/rc";
  exec.stop = "/bin/sh /etc/rc.shutdown";
  exec.consolelog = "/var/log/jail_console_${name}.log";

  # PERMISSIONS
  allow.raw_sockets;
  exec.clean;
  mount.devfs;
  devfs_ruleset = 4;  # Ensure that you use a devfs ruleset that exposes all basic devices
  allow.mount;
  allow.mount.devfs;
  allow.mount.fdescfs;
  allow.mount.procfs;
  allow.mount.linprocfs;
  allow.mount.linsysfs;
  allow.mount.tmpfs;
  enforce_statfs = 1;

  # HOSTNAME/PATH
  host.hostname = "${name}";
  path = "/usr/local/jails/containers/${name}";

  # NETWORK
  ip4.addr = 192.168.4.1;
  interface = lan0;

  # LINUX SPECIAL MOUNTS
  mount += "devfs       $path/linux/dev     devfs     rw  0 0";
  mount += "tmpfs       $path/linux/dev/shm tmpfs     rw,size=1g,mode=1777  0 0";
  mount += "fdescfs     $path/linux/dev/fd  fdescfs   rw,linrdlnk 0 0";
  mount += "linprocfs   $path/linux/proc    linprocfs rw  0 0";
  mount += "linsysfs    $path/linux/sys     linsysfs  rw  0 0";

  # CONTAINER VOLUME MOUNTS
  mount += "/usr/local/jails/volumes/immich_server_data   $path/linux/data  nullfs  rw  0 0";
}
```

> I actually use vnet networking and not simple networking. It's not relevant for this demo though.

If you put the `jail.conf` in its proper place, you can now control the jail with `service`:

```sh
[host]$ service jail start immich-server
Starting jails: immich-server.
```

### Creating the `rc` service

Now, we need to configure the containerized app to start when the jail starts. We can use a simple `rc` service for this! Let's `jexec` into the jail and create a service file.

```sh
[host]$ jexec immich-server /bin/sh
[immich-server]$ vi /usr/local/etc/rc.d/immich_server
```

My service looks like this. The idea is to run the application in a `chroot`. The startup command is improvised based on the container image `config.json` in the extracted `unpacked` directory.

```
#!/bin/sh

# PROVIDE: immich_server
# REQUIRE: NETWORKING
# KEYWORD: shutdown

. /etc/rc.subr

name="immich_server"
rcvar="${name}_enable"
pidfile="/var/run/${name}.pid"
logfile="/var/log/${name}.log"

load_rc_config $name
: ${immich_server_enable:="NO"}
: ${immich_server_envfile:="/usr/local/etc/immich_server.env"}
: ${immich_server_root:="/image/immich-server"}
: ${immich_server_user:="root"}
: ${immich_server_group:="wheel"}

start_cmd="${name}_start"
stop_cmd="${name}_stop"
status_cmd="${name}_status"

immich_server_start() {
    echo "Starting ${name}."
    set -a    # export all variables
    . ${immich_server_envfile}
    set +a
    /usr/sbin/daemon -P ${pidfile} -o ${logfile} \
        /usr/sbin/chroot \
        -u ${immich_server_user} -g ${immich_server_group} \
        ${immich_server_root} \
        /usr/local/bin/node /usr/src/app/server/dist/main.js
}

immich_server_stop() {
    if [ -f ${pidfile} ]; then
        echo "Stopping ${name}."
        kill $(cat ${pidfile}) 2>/dev/null
        rm -f ${pidfile}
    else
        echo "${name} is not running."
    fi
}

immich_server_status() {
    if [ -f ${pidfile} ] && kill -0 $(cat ${pidfile}) 2>/dev/null; then
        echo "${name} is running as pid $(cat ${pidfile})."
    else
        echo "${name} is not running."
        return 1
    fi
}

run_rc_command "$1"
```

Now, some things don't map to this filesystem-focused way of running container apps. Containerfiles can define:

- environment variables
- exposed ports
- user and group ids

You might want to implement these in some way. My own approach can be seen in the `rc` service example: you can supply an envfile with `FOO=bar` style variables and specify user and group with `rc.conf` variables.

```sh
# Set up environment variables in this file
[immich-server]$ touch /usr/local/etc/immich_server.env
[immich-server]$ chmod 600 /usr/local/etc/immich_server.env
```

Enable the service to start automatically on jail startup, and start it once right away:

```sh
[immich-server]$ service immich_server enable
[immich-server]$ service immich_server start
```

### Upgrading the container

I have yet to upgrade to a more recent version of the image, but I'd imagine it is as simple as:

1. stopping the service,
2. unmounting all mountpoints,
3. removing the `/linux` directory, and
3. redoing the steps that download and extract an image into `/linux`, using the new image TAG

Then, a jail restart should bring everything up again.

## Thoughts

I have had a good experience with this setup. It is somewhat _manual_, sure, and I guess some utility scripts could be used for the download and extract part at least, but that doesn't bother me really. Obviously adhoc setups like this could be improved and made more robust/rigorous.

You can also run multiple container images in a single jail with this method. Immich has a separate machine learning container for running face recognition tasks etc. I run that in the same jail with a separate `rc` service.

One fun approach could be to wrap this into a FreeBSD port, and build the image fs with poudriere. A simple `pkg install` could then set up the service and everything. Something to consider!
