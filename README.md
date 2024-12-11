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

