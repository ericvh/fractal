#!/bin/bash 
qemu-system-aarch64 -machine virt -cpu max --kernel ../artifacts/Image --initrd ../artifacts/initramfs.cpio -append 'ip=on' -netdev user,id=n1,hostfwd=tcp:0.0.0.0:17010-:17010,net=192.168.1.0/24,host=192.168.1.1 -device virtio-net-pci,netdev=n1 -serial mon:stdio -nographic

