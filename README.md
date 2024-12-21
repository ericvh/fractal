# fractal
harness for creating minimal u-root based systems that use (potentially multiple) container images

# goal
* set up a minimal initramfs based system that allows me to connect to it and create containers based off OCI images
* the OCI images come from elsewhere - either across a virtiofs, virtfs, or other distributed file system link
* this is very kata-like with some differences
    * we start one instance of the VM and start multiple containers within it
    * we can use this on hardware instead of a VM (with some caveats!)
    * (MAYBE) we can use attestation protocols to verify the base stack prior to deploying containers on it
    * (MAYBE) we can dynamically change the mount structure of a particular namespace by adding (or potentially removing) layers from different OCI stackable filesystems
    * (MAYBE) we can share a common repo of filesystem images, but this will need coordination with host containerd

# methodology

Uses u-root and cpu to bootstrap, eventually I think we can move away from cpu to something a bit more fit for purpose

# variants

## fractal-linux

In this simplified form, we start a u-root initrd into the shell and backmount the host root directories via virtfs and bind it to make a root file system before dropping into an interactive shell.  This has the effect of cpu without using cpu/cpud and does so without network and ssh.

## fractal-mac

On mac many things don't work the way we want, in particular we can't just mount the host file system to get executables (unless you happen to have an unpacked linux somewhere) -- so the default mounts don't really work or matter.
We can mount /Users but we cant really do much beyond that

## fractal-cpud

This version is uses vanilla cpud (which can still be overriden to use virtfs or virtiofs via namespace or fstab options) to coordinate the access.  It

## fractal-ccpu (TODO)

This version is the same as cpud but includes containerd/ctr which cpu can use to mount a container filesystem from the host

## other variants to play with (TODO)
    - use vsock instead of network
    - don't encrypt traffic over ssh
    - don't use ssh at all - just use a RESTful API or console
