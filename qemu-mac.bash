#!/bin/bash 
qemu-system-aarch64 -machine virt -accel hvf -cpu max -m 4096M\
  --kernel Image --initrd initramfs.cpio \
  -append 'ip=on' \
  -netdev user,id=n1,hostfwd=tcp:0.0.0.0:17010-:17010,net=192.168.1.0/24,host=192.168.1.1 \
  -device virtio-net-pci,netdev=n1 \
  -serial mon:stdio -nographic \
  -fsdev local,security_model=passthrough,id=fsdev0,path=/ \
  -object rng-random,filename=/dev/urandom,id=rng0 \
  -device virtio-rng-pci,rng=rng0 \
  -device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=FM 
